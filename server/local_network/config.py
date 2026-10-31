from pathlib import Path

from pydantic_settings import BaseSettings, SettingsConfigDict

BASE_DIR = Path(__file__).resolve().parents[1]


class Settings(BaseSettings):
    app_name: str = "POS Local Network Server"
    app_env: str = "development"
    database_url: str = f"sqlite:///{BASE_DIR / 'data' / 'local_network.db'}"
    bind_host: str = "0.0.0.0"
    bind_port: int = 8000
    jwt_secret: str = "change-this-secret"
    jwt_exp_minutes: int = 60 * 24
    admin_username: str = "admin"
    admin_password: str = "admin123"
    allowed_origins: str = "*"
    model_config = SettingsConfigDict(
        env_file=str(BASE_DIR / ".env.localnetwork"),
        extra="ignore",
    )


settings = Settings()
