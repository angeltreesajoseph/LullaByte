from unittest.mock import AsyncMock, Mock
from types import SimpleNamespace
from threading import get_ident
import pytest
from fastapi import Depends
from fastapi.testclient import TestClient
from fastapi.security import HTTPAuthorizationCredentials
from sqlalchemy import text, event
from app.main import create_app
from app.core.settings import Settings
from app.database.session import get_db_session
from app.auth.dependencies import get_current_user, get_verified_identity
from app.auth.firebase import VerifiedIdentity
from app.models import User

def test_health_exposes_release_and_server_timing_without_private_data(monkeypatch):
    monkeypatch.setenv('RENDER_GIT_COMMIT', 'abcdef0123456789')
    app = create_app(Settings(environment='test', database_url=None, sharing_push_enabled=False))
    with TestClient(app) as client:
        response = client.get('/health')
    assert response.headers['X-API-Revision'] == 'abcdef012345'
    assert response.headers['Server-Timing'].startswith('app;dur=')

def test_requests_reuse_app_pool_and_shutdown_disposes_it(tmp_path, monkeypatch):
    import app.database.session as db
    original = db.create_session_factory
    created, disposed = [], []
    def create(settings):
        factory = original(settings)
        created.append(factory)
        event.listen(factory.kw['bind'].sync_engine, 'engine_disposed', lambda engine: disposed.append(engine))
        return factory
    monkeypatch.setattr(db, 'create_session_factory', create)
    settings = Settings(environment='test', database_url=f'sqlite+aiosqlite:///{tmp_path / "pool.sqlite"}', sharing_push_enabled=False)
    app = create_app(settings)
    @app.get('/pool-test')
    async def probe(session=Depends(get_db_session)):
        return {'value': (await session.execute(text('SELECT 1'))).scalar_one()}
    with TestClient(app) as client:
        assert client.get('/pool-test').json() == {'value': 1}
        assert client.get('/pool-test').json() == {'value': 1}
        assert len(created) == 1
        assert disposed == []
    assert len(disposed) == 1
    assert app.state.database_sessions is None

@pytest.mark.asyncio
async def test_unchanged_identity_does_not_commit_and_reload_user():
    user = User(firebase_uid='uid', email='parent@example.com', display_name='Parent', is_active=True)
    result = Mock()
    result.scalar_one_or_none.return_value = user
    session = SimpleNamespace(execute=AsyncMock(return_value=result), commit=AsyncMock(),
        refresh=AsyncMock(), is_modified=Mock(return_value=False))
    actual = await get_current_user(VerifiedIdentity('uid', user.email, user.display_name, True), session)
    assert actual is user
    session.commit.assert_not_awaited()
    session.refresh.assert_not_awaited()

@pytest.mark.asyncio
async def test_changed_identity_is_still_persisted():
    user = User(firebase_uid='uid', email='parent@example.com', display_name='Old', is_active=True)
    result = Mock()
    result.scalar_one_or_none.return_value = user
    session = SimpleNamespace(execute=AsyncMock(return_value=result), commit=AsyncMock(),
        refresh=AsyncMock(), is_modified=Mock(return_value=True))
    await get_current_user(VerifiedIdentity('uid', user.email, 'New', True), session)
    assert user.display_name == 'New'
    session.commit.assert_awaited_once()

@pytest.mark.asyncio
async def test_token_verification_does_not_block_async_request_loop():
    loop_thread = get_ident()
    identity = VerifiedIdentity('uid', 'parent@example.com', 'Parent', True)
    class Verifier:
        def verify(self, token):
            assert token == 'test-token'
            assert get_ident() != loop_thread
            return identity
    actual = await get_verified_identity(HTTPAuthorizationCredentials(scheme='Bearer', credentials='test-token'), Verifier())
    assert actual is identity

