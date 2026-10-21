from collections.abc import AsyncIterator
from datetime import datetime, timedelta, timezone
from uuid import uuid4
import pytest_asyncio
from fastapi.testclient import TestClient
from sqlalchemy.ext.asyncio import AsyncSession, async_sessionmaker, create_async_engine
from app.auth.dependencies import get_current_user, get_verified_identity
from app.auth.firebase import VerifiedIdentity
from app.core.settings import Settings
from app.database.base import Base
from app.database.session import get_db_session
from app.main import create_app
from app.models import User
from app.models import BabyShare
from sqlalchemy import select
import pytest

@pytest_asyncio.fixture
async def sharing_client():
    engine = create_async_engine('sqlite+aiosqlite:///:memory:')
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)
    factory = async_sessionmaker(engine, expire_on_commit=False)
    people = [User(id=uuid4(), firebase_uid=str(i), email=e) for i, e in enumerate(
        ['parent@example.com', 'care@example.com', 'stranger@example.com'])]
    async with factory() as session:
        session.add_all(people)
        await session.commit()
    state = {'person': 0, 'verified': True, 'factory': factory}
    async def db() -> AsyncIterator[AsyncSession]:
        async with factory() as session:
            yield session
    async def user(): return people[state['person']]
    async def identity():
        p = people[state['person']]
        return VerifiedIdentity(p.firebase_uid, p.email, None, state['verified'])
    app = create_app(Settings(environment='test', log_level='CRITICAL'))
    app.dependency_overrides[get_current_user] = user
    app.dependency_overrides[get_verified_identity] = identity
    app.dependency_overrides[get_db_session] = db
    with TestClient(app) as client:
        yield client, state
    await engine.dispose()

def test_invite_accept_roles_twins_and_revoke(sharing_client):
    c, state = sharing_client
    one = c.post('/api/v1/babies', json={'name': 'One'}).json()['data']['id']
    two = c.post('/api/v1/babies', json={'name': 'Two'}).json()['data']['id']
    share = c.post(f'/api/v1/sharing/babies/{one}', json={'email': 'Care@Example.com', 'role': 'viewer'})
    assert share.status_code == 201
    sid = share.json()['data']['id']
    assert c.post(f'/api/v1/sharing/babies/{one}', json={'email': 'care@example.com'}).status_code == 409
    state['person'] = 2
    assert c.post(f'/api/v1/sharing/{sid}/accept').status_code == 404
    assert c.delete(f'/api/v1/sharing/{sid}').status_code == 404
    state['person'] = 1
    assert c.get('/api/v1/babies').json()['data'] == []
    state['verified'] = False
    assert c.get('/api/v1/sharing').json()['data'] == []
    assert c.post(f'/api/v1/sharing/{sid}/accept').status_code == 403
    state['verified'] = True
    assert len(c.get('/api/v1/sharing').json()['data']) == 1
    assert c.post(f'/api/v1/sharing/{sid}/accept').status_code == 200
    assert c.post(f'/api/v1/sharing/{sid}/accept').status_code == 409
    assert [b['id'] for b in c.get('/api/v1/babies').json()['data']] == [one]
    assert c.get(f'/api/v1/babies/{two}').status_code == 404
    assert c.get(f'/api/v1/babies/{one}').json()['data']['access_role'] == 'viewer'
    endpoint = f'/api/v1/babies/{one}/trackers/feeding'
    assert c.put(endpoint, json=[]).status_code == 403
    assert c.patch(f'/api/v1/babies/{one}', json={'name': 'Bad'}).status_code == 404
    assert c.patch(f'/api/v1/sharing/{sid}', json={'role': 'caregiver'}).status_code == 404
    state['person'] = 0
    assert c.patch(f'/api/v1/sharing/{sid}', json={'role': 'caregiver'}).status_code == 200
    state['person'] = 1
    assert c.put(endpoint, json=[{'type': 'bottle', 'amount_ml': 50}]).status_code == 200
    assert c.patch(f'/api/v1/babies/{one}', json={'name': 'Bad'}).status_code == 404
    state['person'] = 0
    assert c.get(f'/api/v1/babies/{one}').json()['data']['tracker_data']['feeding'][0]['amount_ml'] == 50
    assert c.delete(f'/api/v1/sharing/{sid}').status_code == 200
    state['person'] = 1
    assert c.get(f'/api/v1/babies/{one}').status_code == 404
    assert c.put(endpoint, json=[]).status_code == 404
    assert c.get('/api/v1/babies').json()['data'] == []

def test_decline_and_invalid_invites(sharing_client):
    c, state = sharing_client
    baby = c.post('/api/v1/babies', json={'name': 'One'}).json()['data']['id']
    assert c.post(f'/api/v1/sharing/babies/{baby}', json={'email': 'bad'}).status_code == 422
    assert c.post(f'/api/v1/sharing/babies/{baby}', json={'email': 'parent@example.com'}).status_code == 400
    assert c.post(f'/api/v1/sharing/babies/{baby}', json={'email': 'care@example.com', 'role': 'owner'}).status_code == 422
    sid = c.post(f'/api/v1/sharing/babies/{baby}', json={'email': 'care@example.com'}).json()['data']['id']
    state['person'] = 1
    assert c.delete(f'/api/v1/sharing/{sid}').status_code == 200
    assert c.get('/api/v1/babies').json()['data'] == []

@pytest.mark.asyncio
async def test_expired_invite_and_member_leaving(sharing_client):
    c, state = sharing_client
    baby = c.post('/api/v1/babies', json={'name': 'One'}).json()['data']['id']
    sid = c.post(f'/api/v1/sharing/babies/{baby}', json={'email': 'care@example.com'}).json()['data']['id']
    async with state['factory']() as session:
        share = (await session.execute(select(BabyShare))).scalar_one()
        share.expires_at = datetime.now(timezone.utc) - timedelta(days=1)
        await session.commit()
    state['person'] = 1
    assert c.post(f'/api/v1/sharing/{sid}/accept').status_code == 410
    assert c.get('/api/v1/babies').json()['data'] == []
    state['person'] = 0
    assert c.delete(f'/api/v1/sharing/{sid}').status_code == 200
    sid = c.post(f'/api/v1/sharing/babies/{baby}', json={'email': 'care@example.com'}).json()['data']['id']
    state['person'] = 1
    assert c.post(f'/api/v1/sharing/{sid}/accept').status_code == 200
    assert c.delete(f'/api/v1/sharing/{sid}').status_code == 200
    assert c.get(f'/api/v1/babies/{baby}').status_code == 404
