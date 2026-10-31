"""Local network sync package for the POS app."""

from server.local_network.config import settings
from server.local_network.database import init_db

__all__ = ["settings", "init_db"]
