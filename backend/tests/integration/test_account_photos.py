import base64
from uuid import uuid4
import pytest_asyncio
from fastapi.testclient import TestClient
from sqlalchemy.ext.asyncio import create_async_engine, async_sessionmaker
from app.auth.dependencies import get_current_user
from app.database.base import Base
from app.database.session import get_db_session
from app.core.settings import Settings
from app.main import create_app
from app.models import User

PHOTO = 'data:image/png;base64,' + base64.b64encode(b'\x89PNG\r\n\x1a\nexample').decode()


@pytest_asyncio.fixture
async def photo_api():
    engine = create_async_engine('sqlite+aiosqlite:///:memory:')
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)
    factory = async_sessionmaker(engine, expire_on_commit=False)
    users = [User(id=uuid4(), firebase_uid=f'photo-{i}', email=f'{i}@example.com') for i in range(2)]
    async with factory() as session:
        session.add_all(users)
        await session.commit()
    selected = [users[0]]
    async def current():
        return selected[0]
    async def db():
        async with factory() as session:
            yield session
    app = create_app(Settings(environment='test', log_level='CRITICAL'))
    app.dependency_overrides[get_current_user] = current
    app.dependency_overrides[get_db_session] = db
    with TestClient(app) as client:
        yield client, selected, users
    await engine.dispose()


def test_photo_persists_and_is_private_to_account(photo_api):
    client, selected, users = photo_api
    endpoint = '/api/v1/account/me/photo'
    assert client.get(endpoint).json()['data']['photo_data'] is None
    assert client.put(endpoint, json={'photo_data': PHOTO}).status_code == 200
    assert client.get(endpoint).json()['data']['photo_data'] == PHOTO
    selected[0] = users[1]
    assert client.get(endpoint).json()['data']['photo_data'] is None
    assert client.put(endpoint, json={'photo_data': None}).status_code == 200
    selected[0] = users[0]
    assert client.get(endpoint).json()['data']['photo_data'] == PHOTO
    assert client.put(endpoint, json={'photo_data': None}).status_code == 200
    assert client.get(endpoint).json()['data']['photo_data'] is None


def test_invalid_or_oversized_photo_cannot_replace_saved_photo(photo_api):
    client, _, _ = photo_api
    endpoint = '/api/v1/account/me/photo'
    client.put(endpoint, json={'photo_data': PHOTO})
    for invalid in ['not-a-photo', 'data:image/png;base64,!!!!', 'data:image/svg+xml;base64,PHN2Zz4=', 'x' * 500001]:
        assert client.put(endpoint, json={'photo_data': invalid}).status_code == 422
    assert client.put(endpoint, json={'photo_data': PHOTO, 'user_id': str(uuid4())}).status_code == 422
    assert client.get(endpoint).json()['data']['photo_data'] == PHOTO


def test_photo_routes_require_authentication():
    app = create_app(Settings(environment='test', log_level='CRITICAL'))
    with TestClient(app) as client:
        assert client.get('/api/v1/account/me/photo').status_code == 401
        assert client.put('/api/v1/account/me/photo', json={'photo_data': PHOTO}).status_code == 401
