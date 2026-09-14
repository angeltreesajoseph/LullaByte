"""Settings validation tests."""

import pytest
from pydantic import ValidationError

from app.core.settings import Settings


def test_settings_have_safe_development_defaults() -> None:
    settings = Settings(_env_file=None)
    assert settings.environment == "development"
    assert settings.debug is False
    assert settings.api_v1_prefix == "/api/v1"
    assert "http://localhost" in settings.cors_allowed_origins


def test_invalid_environment_is_rejected() -> None:
    with pytest.raises(ValidationError):
        Settings(environment="invalid", _env_file=None)

