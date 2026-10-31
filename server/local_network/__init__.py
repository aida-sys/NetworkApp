from __future__ import annotations

from datetime import datetime
from pathlib import Path
from typing import Any, Iterable

from sqlalchemy import create_engine, event
from sqlalchemy.orm import DeclarativeBase, Mapped, Session, mapped_column, sessionmaker

from server.local_network.config import settings


class Base(DeclarativeBase):
    pass


engine = (
    create_engine(settings.database_url, pool_pre_ping=True)
    if settings.database_url.startswith("postgresql")
    else create_engine(settings.database_url, connect_args={"check_same_thread": False})
)

SessionLocal = sessionmaker(bind=engine, autoflush=False, autocommit=False)


@event.listens_for(engine, "connect")
def set_sqlite_pragma(dbapi_connection, connection_record):  # pragma: no cover
    import sqlite3

    if isinstance(dbapi_connection, sqlite3.Connection):
        dbapi_connection.execute("PRAGMA foreign_keys = ON")
        dbapi_connection.execute("PRAGMA journal_mode = WAL")
        dbapi_connection.execute("PRAGMA busy_timeout = 5000")


class Device(Base):
    __tablename__ = "sync_devices"

    id: Mapped[int] = mapped_column(primary_key=True, index=True)
    device_code: Mapped[str] = mapped_column(unique=True, index=True, nullable=False)
    device_name: Mapped[str] = mapped_column(nullable=False)
    api_token: Mapped[str] = mapped_column(unique=True, index=True, nullable=False)
    last_seen_at: Mapped[datetime | None] = mapped_column(nullable=True)
    created_at: Mapped[datetime] = mapped_column(default=datetime.utcnow, nullable=False)


class Product(Base):
    __tablename__ = "products"

    id: Mapped[int] = mapped_column(primary_key=True, index=True)
    sku: Mapped[str] = mapped_column(index=True, unique=True, nullable=False)
    barcode: Mapped[str | None] = mapped_column(index=True, nullable=True)
    name: Mapped[str] = mapped_column(nullable=False)
    category: Mapped[str | None] = mapped_column(nullable=True)
    purchase_price: Mapped[int] = mapped_column(default=0, nullable=False)
    selling_price: Mapped[int] = mapped_column(default=0, nullable=False)
    stock: Mapped[int] = mapped_column(default=0, nullable=False)
    is_active: Mapped[bool] = mapped_column(default=True, nullable=False)
    updated_at: Mapped[datetime] = mapped_column(default=datetime.utcnow, nullable=False)
    created_at: Mapped[datetime] = mapped_column(default=datetime.utcnow, nullable=False)


class Sale(Base):
    __tablename__ = "sales"

    id: Mapped[int] = mapped_column(primary_key=True, index=True)
    source_device_id: Mapped[str] = mapped_column(nullable=False, index=True)
    invoice_number: Mapped[str] = mapped_column(unique=True, index=True, nullable=False)
    total_amount: Mapped[int] = mapped_column(default=0, nullable=False)
    status: Mapped[str] = mapped_column(default="paid", nullable=False)
    created_at: Mapped[datetime] = mapped_column(default=datetime.utcnow, nullable=False)
    updated_at: Mapped[datetime] = mapped_column(default=datetime.utcnow, nullable=False)


class SaleItem(Base):
    __tablename__ = "sale_items"

    id: Mapped[int] = mapped_column(primary_key=True, index=True)
    sale_id: Mapped[int] = mapped_column(nullable=False, index=True)
    product_sku: Mapped[str] = mapped_column(nullable=False, index=True)
    product_name: Mapped[str] = mapped_column(nullable=False)
    qty: Mapped[int] = mapped_column(default=1, nullable=False)
    unit_price: Mapped[int] = mapped_column(default=0, nullable=False)
    subtotal: Mapped[int] = mapped_column(default=0, nullable=False)
    created_at: Mapped[datetime] = mapped_column(default=datetime.utcnow, nullable=False)


class Payment(Base):
    __tablename__ = "payments"

    id: Mapped[int] = mapped_column(primary_key=True, index=True)
    sale_id: Mapped[int] = mapped_column(nullable=False, index=True)
    payment_method: Mapped[str] = mapped_column(default="cash", nullable=False)
    amount: Mapped[int] = mapped_column(default=0, nullable=False)
    created_at: Mapped[datetime] = mapped_column(default=datetime.utcnow, nullable=False)


class InventoryMovement(Base):
    __tablename__ = "inventory_movements"

    id: Mapped[int] = mapped_column(primary_key=True, index=True)
    product_sku: Mapped[str] = mapped_column(nullable=False, index=True)
    direction: Mapped[str] = mapped_column(nullable=False)
    qty: Mapped[int] = mapped_column(default=0, nullable=False)
    reason: Mapped[str] = mapped_column(default="sync", nullable=False)
    source_device_id: Mapped[str] = mapped_column(nullable=False, index=True)
    created_at: Mapped[datetime] = mapped_column(default=datetime.utcnow, nullable=False)


class SyncLog(Base):
    __tablename__ = "sync_logs"

    id: Mapped[int] = mapped_column(primary_key=True, index=True)
    device_code: Mapped[str | None] = mapped_column(nullable=True, index=True)
    action: Mapped[str] = mapped_column(nullable=False, index=True)
    status: Mapped[str] = mapped_column(default="ok", nullable=False)
    detail: Mapped[str | None] = mapped_column(nullable=True)
    created_at: Mapped[datetime] = mapped_column(default=datetime.utcnow, nullable=False)


def init_db() -> None:
    data_dir = Path(__file__).resolve().parents[1] / "data"
    data_dir.mkdir(parents=True, exist_ok=True)
    Base.metadata.create_all(bind=engine)


def as_dict(obj: Any) -> dict[str, Any]:
    if obj is None:
        return {}
    data: dict[str, Any] = {}
    for key, value in obj.__dict__.items():
        if key.startswith("_"):
            continue
        if isinstance(value, datetime):
            data[key] = value.isoformat()
        else:
            data[key] = value
    return data


def simple_dict_list(items: Iterable[Any]) -> list[dict[str, Any]]:
    return [as_dict(item) for item in items]


def make_device_token() -> str:
    import secrets

    return secrets.token_urlsafe(24)


__all__ = [
    "Base",
    "Device",
    "Product",
    "Sale",
    "SaleItem",
    "Payment",
    "InventoryMovement",
    "SyncLog",
    "SessionLocal",
    "init_db",
    "make_device_token",
    "as_dict",
    "simple_dict_list",
]
