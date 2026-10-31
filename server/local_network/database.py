from __future__ import annotations

from datetime import datetime, timezone
from pathlib import Path

from fastapi import Depends, FastAPI, HTTPException, Request
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field
from sqlalchemy.orm import Session

from server.local_network.config import settings
from server.local_network.database import (
    Device,
    InventoryMovement,
    Payment,
    Product,
    Sale,
    SaleItem,
    SyncLog,
    init_db,
)


class LoginPayload(BaseModel):
    username: str
    password: str


class DeviceRegisterPayload(BaseModel):
    device_name: str = Field(..., min_length=2)
    device_code: str = Field(..., min_length=2)


class ProductPayload(BaseModel):
    sku: str
    name: str
    barcode: str | None = None
    category: str | None = None
    purchase_price: int = 0
    selling_price: int = 0
    stock: int = 0
    is_active: bool = True


class SaleItemPayload(BaseModel):
    sku: str
    name: str
    qty: int = 1
    unit_price: int = 0
    subtotal: int = 0


class PaymentPayload(BaseModel):
    method: str = "cash"
    amount: int = 0


class SalePayload(BaseModel):
    invoice_number: str
    total_amount: int = 0
    status: str = "paid"
    items: list[SaleItemPayload] = []
    payments: list[PaymentPayload] = []


class PushPayload(BaseModel):
    products: list[ProductPayload] = []
    sales: list[SalePayload] = []


app = FastAPI(title=settings.app_name)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.on_event("startup")
def startup_event() -> None:
    init_db()


def get_db() -> Session:
    from server.local_network.database import SessionLocal

    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


def issue_jwt(subject: str) -> str:
    import jwt

    now = datetime.now(timezone.utc)
    payload = {
        "sub": subject,
        "iat": int(now.timestamp()),
        "exp": int((now.timestamp() + settings.jwt_exp_minutes * 60)),
    }
    return jwt.encode(payload, settings.jwt_secret, algorithm="HS256")


def require_auth(request: Request, db: Session = Depends(get_db)) -> str:
    import jwt

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


def get_device_from_header(request: Request, db: Session = Depends(get_db)) -> Device:
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
    import secrets

    return secrets.token_urlsafe(24)


def upsert_products(db: Session, payload: list[dict]) -> list[dict]:
    saved: list[dict] = []
    for item in payload:
        sku = str(item["sku"])
        record = db.query(Product).filter(Product.sku == sku).first()
        if record is None:
            record = Product(
                sku=sku,
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
        saved.append(
            {
                "sku": record.sku,
                "name": record.name,
                "stock": record.stock,
                "selling_price": record.selling_price,
            }
        )
    return saved


def record_sale(db: Session, sale_payload: dict, source_device_id: str) -> dict:
    invoice_number = str(
        sale_payload.get("invoice_number")
        or f"INV-{datetime.now(timezone.utc).strftime('%Y%m%d%H%M%S')}"
    )
    sale = Sale(
        source_device_id=source_device_id,
        invoice_number=invoice_number,
        total_amount=int(sale_payload.get("total_amount", 0)),
        status=str(sale_payload.get("status", "paid")),
    )
    db.add(sale)
    db.flush()

    for item in sale_payload.get("items", []):
        db.add(
            SaleItem(
                sale_id=sale.id,
                product_sku=str(item["sku"]),
                product_name=str(item.get("name") or item["sku"]),
                qty=int(item.get("qty", 1)),
                unit_price=int(item.get("unit_price", 0)),
                subtotal=int(item.get("subtotal", 0)),
            )
        )
        db.add(
            InventoryMovement(
                product_sku=str(item["sku"]),
                direction="out",
                qty=int(item.get("qty", 0)),
                reason="sale",
                source_device_id=source_device_id,
            )
        )

    for payment in sale_payload.get("payments", []):
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


@app.get("/health")
def health() -> dict:
    return {"status": "ok", "app": settings.app_name, "environment": settings.app_env}


@app.post("/api/auth/login")
def login(payload: LoginPayload, db: Session = Depends(get_db)) -> dict:
    if payload.username != settings.admin_username or payload.password != settings.admin_password:
        raise HTTPException(status_code=401, detail="Username atau password salah")
    return {"token": issue_jwt(payload.username), "username": payload.username}


@app.post("/api/device/register")
def register_device(
    payload: DeviceRegisterPayload,
    db: Session = Depends(get_db),
    _: str = Depends(require_auth),
) -> dict:
    existing = db.query(Device).filter(Device.device_code == payload.device_code).first()
    if existing is None:
        device = Device(
            device_code=payload.device_code,
            device_name=payload.device_name,
            api_token=build_device_token(),
            last_seen_at=datetime.now(timezone.utc),
        )
        db.add(device)
        db.commit()
        db.refresh(device)
        return {
            "device_id": device.id,
            "device_code": device.device_code,
            "device_name": device.device_name,
            "api_token": device.api_token,
        }

    existing.device_name = payload.device_name
    existing.last_seen_at = datetime.now(timezone.utc)
    db.commit()
    return {
        "device_id": existing.id,
        "device_code": existing.device_code,
        "device_name": existing.device_name,
        "api_token": existing.api_token,
    }


@app.get("/api/sync/status")
def sync_status(db: Session = Depends(get_db), _: Device = Depends(get_device_from_header)) -> dict:
    products_count = db.query(Product).count()
    sales_count = db.query(Sale).count()
    devices_count = db.query(Device).count()
    latest_sync = db.query(SyncLog).order_by(SyncLog.created_at.desc()).first()
    return {
        "products_count": products_count,
        "sales_count": sales_count,
        "devices_count": devices_count,
        "latest_sync": latest_sync.created_at.isoformat() if latest_sync else None,
        "server_time": datetime.now(timezone.utc).isoformat(),
    }


@app.get("/api/products")
def list_products(db: Session = Depends(get_db), _: Device = Depends(get_device_from_header)) -> list[dict]:
    items = db.query(Product).order_by(Product.name.asc()).all()
    return [
        {
            "sku": item.sku,
            "barcode": item.barcode,
            "name": item.name,
            "category": item.category,
            "purchase_price": item.purchase_price,
            "selling_price": item.selling_price,
            "stock": item.stock,
            "is_active": item.is_active,
            "updated_at": item.updated_at.isoformat(),
        }
        for item in items
    ]


@app.post("/api/products/bulk")
def bulk_products(
    payload: list[ProductPayload],
    db: Session = Depends(get_db),
    device: Device = Depends(get_device_from_header),
) -> dict:
    saved = upsert_products(db, [item.model_dump() for item in payload])
    create_sync_log(db, device.device_code, "products_bulk", "ok", f"{len(payload)} produk disinkronkan")
    return {"status": "ok", "count": len(payload), "saved": saved}


@app.get("/api/sales")
def list_sales(db: Session = Depends(get_db), _: Device = Depends(get_device_from_header)) -> list[dict]:
    sales = db.query(Sale).order_by(Sale.created_at.desc()).all()
    results: list[dict] = []
    for sale in sales:
        items = db.query(SaleItem).filter(SaleItem.sale_id == sale.id).all()
        results.append(
            {
                "sale_id": sale.id,
                "invoice_number": sale.invoice_number,
                "source_device_id": sale.source_device_id,
                "total_amount": sale.total_amount,
                "status": sale.status,
                "created_at": sale.created_at.isoformat(),
                "items": [
                    {
                        "sku": item.product_sku,
                        "name": item.product_name,
                        "qty": item.qty,
                        "unit_price": item.unit_price,
                        "subtotal": item.subtotal,
                    }
                    for item in items
                ],
            }
        )
    return results


@app.post("/api/sales/bulk")
def bulk_sales(
    payload: list[SalePayload],
    db: Session = Depends(get_db),
    device: Device = Depends(get_device_from_header),
) -> dict:
    saved = []
    for item in payload:
        saved.append(record_sale(db, item.model_dump(), device.device_code))
    create_sync_log(db, device.device_code, "sales_bulk", "ok", f"{len(payload)} transaksi disinkronkan")
    return {"status": "ok", "count": len(payload), "saved": saved}


@app.post("/api/sync/push")
def sync_push(payload: PushPayload, db: Session = Depends(get_db), device: Device = Depends(get_device_from_header)) -> dict:
    product_count = len(upsert_products(db, [p.model_dump() for p in payload.products]))
    sale_count = 0
    for sale in payload.sales:
        record_sale(db, sale.model_dump(), device.device_code)
        sale_count += 1
    create_sync_log(db, device.device_code, "push", "ok", f"{product_count} produk, {sale_count} penjualan")
    return {"status": "ok", "products_saved": product_count, "sales_saved": sale_count}


@app.get("/api/sync/logs")
def sync_logs(db: Session = Depends(get_db), _: Device = Depends(get_device_from_header)) -> list[dict]:
    rows = db.query(SyncLog).order_by(SyncLog.created_at.desc()).limit(50).all()
    return [
        {
            "id": row.id,
            "device_code": row.device_code,
            "action": row.action,
            "status": row.status,
            "detail": row.detail,
            "created_at": row.created_at.isoformat(),
        }
        for row in rows
    ]


@app.get("/api/devices")
def list_devices(db: Session = Depends(get_db), _: str = Depends(require_auth)) -> list[dict]:
    rows = db.query(Device).order_by(Device.created_at.desc()).all()
    return [
        {
            "id": row.id,
            "device_code": row.device_code,
            "device_name": row.device_name,
            "api_token": row.api_token,
            "created_at": row.created_at.isoformat(),
            "last_seen_at": row.last_seen_at.isoformat() if row.last_seen_at else None,
        }
        for row in rows
    ]


@app.get("/api/summary")
def summary(db: Session = Depends(get_db), _: str = Depends(require_auth)) -> dict:
    product_count = db.query(Product).count()
    sales_count = db.query(Sale).count()
    total_revenue = sum(sale.total_amount for sale in db.query(Sale).all())
    return {
        "products_count": product_count,
        "sales_count": sales_count,
        "total_revenue": total_revenue,
        "server_time": datetime.now(timezone.utc).isoformat(),
    }


if __name__ == "__main__":
    import uvicorn

    uvicorn.run(app, host=settings.bind_host, port=settings.bind_port)
