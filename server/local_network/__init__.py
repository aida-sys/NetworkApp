from __future__ import annotations

from datetime import datetime, timezone
from typing import Any

from fastapi import Depends, FastAPI, HTTPException, Request
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field
from sqlalchemy.orm import Session

from server.local_network.config import settings
from server.local_network.database import (
    Device,
    Product,
    Sale,
    SaleItem,
    SessionLocal,
    SyncLog,
    init_db,
    make_device_token,
    simple_dict_list,
)
from server.local_network.models import (
    build_device_token,
    create_sync_log,
    decode_jwt,
    get_db,
    get_device_from_header,
    issue_jwt,
    require_auth,
    record_sale,
    upsert_products,
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


@app.get("/health")
def health() -> dict[str, Any]:
    return {"status": "ok", "app": settings.app_name, "environment": settings.app_env}


@app.post("/api/auth/login")
def login(payload: LoginPayload, db: Session = Depends(get_db)) -> dict[str, Any]:
    if payload.username != settings.admin_username or payload.password != settings.admin_password:
        raise HTTPException(status_code=401, detail="Username atau password salah")
    return {"token": issue_jwt(payload.username), "username": payload.username}


@app.post("/api/device/register")
def register_device(
    payload: DeviceRegisterPayload,
    db: Session = Depends(get_db),
    _: str = Depends(require_auth),
) -> dict[str, Any]:
    existing = db.query(Device).filter(Device.device_code == payload.device_code).first()
    if existing is None:
        token = build_device_token()
        existing = Device(
            device_code=payload.device_code,
            device_name=payload.device_name,
            api_token=token,
            last_seen_at=datetime.now(timezone.utc),
        )
        db.add(existing)
        db.commit()
        db.refresh(existing)
        return {
            "device_id": existing.id,
            "device_code": existing.device_code,
            "device_name": existing.device_name,
            "api_token": existing.api_token,
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
def sync_status(db: Session = Depends(get_db), _: Device = Depends(get_device_from_header)) -> dict[str, Any]:
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
def list_products(db: Session = Depends(get_db), _: Device = Depends(get_device_from_header)) -> list[dict[str, Any]]:
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
def bulk_products(payload: list[ProductPayload], db: Session = Depends(get_db), device: Device = Depends(get_device_from_header)) -> dict[str, Any]:
    upsert_products(db, [item.model_dump() for item in payload])
    create_sync_log(db, device.device_code, "products_bulk", "ok", f"{len(payload)} produk disinkronkan")
    return {"status": "ok", "count": len(payload)}


@app.get("/api/sales")
def list_sales(db: Session = Depends(get_db), _: Device = Depends(get_device_from_header)) -> list[dict[str, Any]]:
    sales = db.query(Sale).order_by(Sale.created_at.desc()).all()
    result: list[dict[str, Any]] = []
    for sale in sales:
        items = db.query(SaleItem).filter(SaleItem.sale_id == sale.id).all()
        result.append(
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
    return result


@app.post("/api/sales/bulk")
def bulk_sales(payload: list[SalePayload], db: Session = Depends(get_db), device: Device = Depends(get_device_from_header)) -> dict[str, Any]:
    saved = []
    for item in payload:
        saved.append(record_sale(db, item.model_dump(), device.device_code))
    create_sync_log(db, device.device_code, "sales_bulk", "ok", f"{len(payload)} transaksi disinkronkan")
    return {"status": "ok", "count": len(payload), "saved": saved}


@app.post("/api/sync/push")
def sync_push(payload: PushPayload, db: Session = Depends(get_db), device: Device = Depends(get_device_from_header)) -> dict[str, Any]:
    product_count = len(upsert_products(db, [p.model_dump() for p in payload.products]))
    sale_count = 0
    for sale in payload.sales:
        record_sale(db, sale.model_dump(), device.device_code)
        sale_count += 1
    create_sync_log(db, device.device_code, "push", "ok", f"{product_count} produk, {sale_count} penjualan")
    return {"status": "ok", "products_saved": product_count, "sales_saved": sale_count}


@app.get("/api/sync/logs")
def sync_logs(db: Session = Depends(get_db), _: Device = Depends(get_device_from_header)) -> list[dict[str, Any]]:
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
def list_devices(db: Session = Depends(get_db), _: str = Depends(require_auth)) -> list[dict[str, Any]]:
    devices = db.query(Device).order_by(Device.created_at.desc()).all()
    return [
        {
            "id": row.id,
            "device_code": row.device_code,
            "device_name": row.device_name,
            "api_token": row.api_token,
            "created_at": row.created_at.isoformat(),
            "last_seen_at": row.last_seen_at.isoformat() if row.last_seen_at else None,
        }
        for row in devices
    ]


@app.get("/api/summary")
def summary(db: Session = Depends(get_db), _: str = Depends(require_auth)) -> dict[str, Any]:
    product_count = db.query(Product).count()
    sales_count = db.query(Sale).count()
    total_revenue = sum(item.total_amount for item in db.query(Sale).all())
    return {
        "products_count": product_count,
        "sales_count": sales_count,
        "total_revenue": total_revenue,
        "server_time": datetime.now(timezone.utc).isoformat(),
    }


if __name__ == "__main__":
    import uvicorn

    uvicorn.run(app, host=settings.bind_host, port=settings.bind_port)
