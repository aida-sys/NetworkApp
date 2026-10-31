from __future__ import annotations

from datetime import datetime, timedelta, timezone
from typing import Any

import jwt
from fastapi import Depends, HTTPException, Request
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from sqlalchemy.orm import Session

from server.local_network.config import settings
from server.local_network.database import (  # type: ignore
    Device,
    InventoryMovement,
    Payment,
    Product,
    Sale,
    SaleItem,
    SessionLocal,
    SyncLog,
    make_device_token,
)

bearer_scheme = HTTPBearer(auto_error=False)


def issue_jwt(subject: str) -> str:
    now = datetime.now(timezone.utc)
    payload = {
        "sub": subject,
        "iat": int(now.timestamp()),
        "exp": int((now + timedelta(minutes=settings.jwt_exp_minutes)).timestamp()),
    }
    return jwt.encode(payload, settings.jwt_secret, algorithm="HS256")


def decode_jwt(token: str) -> str:
    try:
        payload = jwt.decode(token, settings.jwt_secret, algorithms=["HS256"])
        return str(payload["sub"])
    except Exception as exc:  # pragma: no cover
        raise HTTPException(status_code=401, detail="Token tidak valid") from exc


def get_db() -> Session:
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


def require_auth(request: Request, db: Session = Depends(get_db)) -> str:
    token = request.headers.get("Authorization", "")
    if not token.startswith("Bearer "):
        raise HTTPException(status_code=401, detail="Authorization header wajib ada")
    token_value = token.split(" ", 1)[1].strip()
    try:
        payload = jwt.decode(token_value, settings.jwt_secret, algorithms=["HS256"])
    except Exception as exc:  # pragma: no cover
        raise HTTPException(status_code=401, detail="Token tidak valid") from exc
    username = payload.get("sub")
    if username != settings.admin_username:
        raise HTTPException(status_code=403, detail="Akses tidak diizinkan")
    return username


def get_device_from_header(
    request: Request,
    db: Session = Depends(get_db),
) -> Device:
    token = request.headers.get("X-Device-Token")
    if not token:
        raise HTTPException(status_code=401, detail="X-Device-Token wajib diisi")
    device = db.query(Device).filter(Device.api_token == token).first()
    if device is None:
        raise HTTPException(status_code=401, detail="Device token tidak valid")
    device.last_seen_at = datetime.now(timezone.utc)
    db.commit()
    return device


def build_device_token() -> str:
    return make_device_token()


def upsert_products(db: Session, payload: list[dict[str, Any]]) -> list[dict[str, Any]]:
    saved: list[dict[str, Any]] = []
    for item in payload:
        record = db.query(Product).filter(Product.sku == str(item["sku"])).first()
        if record is None:
            record = Product(
                sku=str(item["sku"]),
                barcode=item.get("barcode"),
                name=str(item["name"]),
                category=item.get("category"),
                purchase_price=int(item.get("purchase_price", 0)),
                selling_price=int(item.get("selling_price", 0)),
                stock=int(item.get("stock", 0)),
                is_active=bool(item.get("is_active", True)),
            )
            db.add(record)
        else:
            record.barcode = item.get("barcode") or record.barcode
            record.name = str(item["name"])
            record.category = item.get("category") or record.category
            record.purchase_price = int(item.get("purchase_price", record.purchase_price))
            record.selling_price = int(item.get("selling_price", record.selling_price))
            record.stock = int(item.get("stock", record.stock))
            record.is_active = bool(item.get("is_active", record.is_active))
        record.updated_at = datetime.now(timezone.utc)
        db.commit()
        saved.append({
            "sku": record.sku,
            "name": record.name,
            "stock": record.stock,
            "selling_price": record.selling_price,
        })
    return saved


def record_sale(db: Session, sale_payload: dict[str, Any], source_device_id: str) -> dict[str, Any]:
    invoice_number = str(sale_payload.get("invoice_number") or f"INV-{datetime.now(timezone.utc).strftime('%Y%m%d%H%M%S')}")
    sale = Sale(
        source_device_id=source_device_id,
        invoice_number=invoice_number,
        total_amount=int(sale_payload.get("total_amount", 0)),
        status=str(sale_payload.get("status", "paid")),
    )
    db.add(sale)
    db.flush()

    for item in sale_payload.get("items", []):
        row = SaleItem(
            sale_id=sale.id,
            product_sku=str(item["sku"]),
            product_name=str(item.get("name") or item["sku"]),
            qty=int(item.get("qty", 1)),
            unit_price=int(item.get("unit_price", 0)),
            subtotal=int(item.get("subtotal", 0)),
        )
        db.add(row)
        db.add(
            InventoryMovement(
                product_sku=str(item["sku"]),
                direction="out",
                qty=int(item.get("qty", 0)),
                reason="sale",
                source_device_id=source_device_id,
            )
        )

    if sale_payload.get("payments"):
        for payment in sale_payload["payments"]:
            db.add(
                Payment(
                    sale_id=sale.id,
                    payment_method=str(payment.get("method", "cash")),
                    amount=int(payment.get("amount", 0)),
                )
            )

    db.commit()
    return {"invoice_number": invoice_number, "sale_id": sale.id}


def create_sync_log(db: Session, device_code: str | None, action: str, status: str, detail: str | None = None) -> None:
    db.add(SyncLog(device_code=device_code, action=action, status=status, detail=detail))
    db.commit()
