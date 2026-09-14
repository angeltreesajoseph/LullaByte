"""Environment-driven application settings."""

from functools import lru_cache
from typing import Literal

from pydantic import Field
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    """Validated runtime configuration.

    Secrets are intentionally absent until authentication and database work is
    introduced. They must never be committed when those integrations land.
    """

    model_config = SettingsConfigDict(
        env_file=(".env", "backend/.env"),
        env_file_encoding="utf-8",
        env_prefix="LULLABYTE_",
        case_sensitive=False,
        extra="ignore",
    )

    app_name: str = "LullaByte API"
    app_version: str = "0.1.0"
    environment: Literal["development", "test", "staging", "production"] = "development"
    debug: bool = False
    api_v1_prefix: str = "/api/v1"
    log_level: Literal["DEBUG", "INFO", "WARNING", "ERROR", "CRITICAL"] = "INFO"
    database_url: str | None = None
    database_echo: bool = False
    firebase_service_account_json: str | None = None
    firebase_project_id: str | None = None
    cors_allowed_origins: list[str] = Field(
        default_factory=lambda: ["http://localhost", "http://127.0.0.1"]
    )


@lru_cache
def get_settings() -> Settings:
    """Return one immutable-by-convention settings instance per process."""

    return Settings()
