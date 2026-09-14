"""Authenticated baby-profile API tests with an in-memory database."""

from collections.abc import AsyncIterator
from uuid import uuid4

import pytest_asyncio
from fastapi.testclient import TestClient
from sqlalchemy.ext.asyncio import AsyncSession, async_sessionmaker, create_async_engine

from app.auth.dependencies import get_current_user
from app.core.settings import Settings
from app.database.base import Base
from app.database.session import get_db_session
from app.main import create_app
from app.models import User


@pytest_asyncio.fixture
async def api_client() -> AsyncIterator[TestClient]:
    engine = create_async_engine("sqlite+aiosqlite:///:memory:")
    async with engine.begin() as connection:
        await connection.run_sync(Base.metadata.create_all)
    factory = async_sessionmaker(engine, expire_on_commit=False)
    owner = User(
        id=uuid4(), firebase_uid="test-user", email="test@example.com", display_name="Test User"
    )

    async def override_session() -> AsyncIterator[AsyncSession]:
        async with factory() as session:
            yield session

    async def override_user() -> User:
        return owner

    application = create_app(Settings(environment="test", log_level="CRITICAL"))
    application.dependency_overrides[get_db_session] = override_session
    application.dependency_overrides[get_current_user] = override_user
    with TestClient(application) as client:
        yield client
    await engine.dispose()


def test_baby_crud_is_scoped_to_authenticated_owner(api_client: TestClient) -> None:
    created = api_client.post(
        "/api/v1/babies", json={"name": "Lily", "gender": "female"}
    )
    assert created.status_code == 201
    baby = created.json()["data"]
    baby_id = baby["id"]
    assert baby["name"] == "Lily"

    listed = api_client.get("/api/v1/babies")
    assert listed.status_code == 200
    assert [item["id"] for item in listed.json()["data"]] == [baby_id]

    updated = api_client.patch(
        f"/api/v1/babies/{baby_id}", json={"name": "Lily Rose"}
    )
    assert updated.status_code == 200
    assert updated.json()["data"]["name"] == "Lily Rose"

    missing = api_client.get(f"/api/v1/babies/{uuid4()}")
    assert missing.status_code == 404


def test_protected_routes_require_bearer_credentials() -> None:
    application = create_app(Settings(environment="test", log_level="CRITICAL"))
    with TestClient(application) as client:
        response = client.get("/api/v1/account/me")

    assert response.status_code == 401
    assert response.headers["WWW-Authenticate"] == "Bearer"
