"""Local Network Sync backend for clustered POS clients."""

from server.local_network.config import settings
from server.local_network.database import init_db

__all__ = ["settings", "init_db"]
