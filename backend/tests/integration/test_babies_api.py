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

def test_care_contacts_save_and_remain_separate(api_client: TestClient):
    one = api_client.post('/api/v1/babies', json={'name': 'One', 'parent_phone': '+91 12345', 'pediatrician_phone': '0481-234567'}).json()['data']
    two = api_client.post('/api/v1/babies', json={'name': 'Two'}).json()['data']
    assert one['parent_phone'] == '+91 12345'
    assert two['parent_phone'] is None
    endpoint = f"/api/v1/babies/{one['id']}"
    assert api_client.patch(endpoint, json={'parent_phone': '55555'}).status_code == 200
    assert api_client.get(endpoint).json()['data']['parent_phone'] == '55555'
    assert api_client.get(f"/api/v1/babies/{two['id']}").json()['data']['parent_phone'] is None
    assert api_client.patch(endpoint, json={'parent_phone': 'not a number'}).status_code == 422
    assert api_client.patch(endpoint, json={'parent_phone': ''}).status_code == 200


def test_protected_routes_require_bearer_credentials() -> None:
    application = create_app(Settings(environment="test", log_level="CRITICAL"))
    with TestClient(application) as client:
        response = client.get("/api/v1/account/me")

    assert response.status_code == 401
    assert response.headers["WWW-Authenticate"] == "Bearer"


def test_vaccinations_are_separate_validated_and_editable(api_client: TestClient) -> None:
    one = api_client.post('/api/v1/babies', json={'name': 'Twin one', 'birth_date': '2024-01-01'}).json()['data']
    two = api_client.post('/api/v1/babies', json={'name': 'Twin two', 'birth_date': '2024-01-01'}).json()['data']
    endpoint = f"/api/v1/babies/{one['id']}/trackers/vaccinations"
    record = {'id': 'bcg', 'name': 'BCG', 'due_date': '2024-01-01T00:00:00',
              'done': True, 'received_date': '2024-01-02T00:00:00',
              'reminder_at': '2027-01-01T09:00:00+05:30'}
    response = api_client.put(endpoint, json=[record])
    assert response.status_code == 200
    assert response.json()['data'][0]['reminder_at'] is None
    reloaded = api_client.get(f"/api/v1/babies/{one['id']}").json()['data']
    assert reloaded['tracker_data']['vaccinations'][0]['done'] is True
    assert api_client.get(f"/api/v1/babies/{two['id']}").json()['data']['tracker_data'] is None
    assert api_client.put(endpoint, json=[{**record, 'received_date': None}]).status_code == 422
    assert api_client.put(endpoint, json=[{**record, 'received_date': '2023-12-01T00:00:00'}]).status_code == 422
    assert api_client.put(endpoint, json=[{**record, 'received_date': '2099-12-01T00:00:00'}]).status_code == 422
    assert api_client.put(endpoint, json=[record, record]).status_code == 422
    undone = api_client.put(endpoint, json=[{**record, 'done': False}])
    assert undone.status_code == 200 and undone.json()['data'][0]['received_date'] is None
    assert api_client.put(endpoint, json=[]).status_code == 200
    assert api_client.put(f'/api/v1/babies/{uuid4()}/trackers/vaccinations', json=[]).status_code == 404


def test_experimental_analysis_and_history_integrity(api_client: TestClient, monkeypatch) -> None:
    from app.services import cry_inference
    monkeypatch.setattr(cry_inference, 'analyze', lambda data: {
        'mode': 'model', 'label': 'hungry', 'result': 'Experimental sound-pattern match: hungry',
        'scores': {'hungry': 60, 'tired': 40}, 'confidence': None, 'warning': 'Experimental only',
    })
    baby = api_client.post('/api/v1/babies', json={'name': 'Chris'}).json()['data']
    endpoint = f"/api/v1/babies/{baby['id']}/cry/analyze"
    payload = {'audio_data': 'YQ==', 'format': 'wav', 'accept_experimental': True}
    assert api_client.post(endpoint, json={**payload, 'accept_experimental': False}).status_code == 400
    assert api_client.post(endpoint, json={**payload, 'audio_data': 'invalid!'}).status_code == 422
    assert api_client.post(f'/api/v1/babies/{uuid4()}/cry/analyze', json=payload).status_code == 404
    saved = api_client.post(endpoint, json=payload)
    assert saved.status_code == 200
    entry = saved.json()['data']['entry']
    assert entry['scores']['hungry'] == 60
    loaded = api_client.get(f"/api/v1/babies/{baby['id']}").json()['data']['tracker_data']['cry']
    assert loaded[0]['mode'] == 'model'
    changed = [{**entry, 'scores': {'hungry': 100}, 'label': 'tired'}]
    result = api_client.put(f"/api/v1/babies/{baby['id']}/trackers/cry", json=changed)
    assert result.json()['data'][0]['scores']['hungry'] == 60
    assert result.json()['data'][0]['label'] == 'hungry'
    assert api_client.put(f"/api/v1/babies/{baby['id']}/trackers/cry", json=[]).status_code == 200


def test_cry_history_stores_audio_without_fabricated_prediction(api_client: TestClient) -> None:
    baby = api_client.post('/api/v1/babies', json={'name': 'Alex'}).json()['data']
    endpoint = f"/api/v1/babies/{baby['id']}/trackers/cry"
    entries = [{'audio_data': 'YQ==', 'format': 'm4a', 'time': '2026-10-03',
                'result': 'Hungry', 'confidence': 99}]
    saved = api_client.put(endpoint, json=entries)
    assert saved.status_code == 200
    assert saved.json()['data'][0]['result'] == 'Analysis unavailable'
    assert saved.json()['data'][0]['confidence'] is None
    reloaded = api_client.get(f"/api/v1/babies/{baby['id']}").json()['data']
    assert reloaded['tracker_data']['cry'][0]['audio_data'] == 'YQ=='
    assert api_client.put(endpoint, json=[{'audio_data': 'invalid!', 'format': 'm4a'}]).status_code == 422
    assert api_client.put(endpoint, json=entries * 21).status_code == 422
    assert api_client.put(f'/api/v1/babies/{uuid4()}/trackers/cry', json=entries).status_code == 404
    assert api_client.put(endpoint, json=[]).status_code == 200
    assert api_client.get(f"/api/v1/babies/{baby['id']}").json()['data']['tracker_data']['cry'] == []


def test_twins_keep_photos_measurements_and_trackers_separate(api_client: TestClient) -> None:
    first = api_client.post('/api/v1/babies', json={
        'name': 'Chris', 'photo_data': 'YQ==', 'head_circumference_cm': 30,
        'blood_group': 'A+',
    }).json()['data']
    second = api_client.post('/api/v1/babies', json={
        'name': 'Alex', 'photo_data': 'Yg==', 'head_circumference_cm': 32,
        'blood_group': 'B-',
    }).json()['data']
    entries = [{'type': 'bottle', 'amount': '90 ml'}]
    assert api_client.put(f"/api/v1/babies/{first['id']}/trackers/feeding", json=entries).status_code == 200
    a = api_client.get(f"/api/v1/babies/{first['id']}").json()['data']
    b = api_client.get(f"/api/v1/babies/{second['id']}").json()['data']
    assert a['photo_data'] == 'YQ==' and b['photo_data'] == 'Yg=='
    assert a['head_circumference_cm'] != b['head_circumference_cm']
    assert a['tracker_data']['feeding'] == entries
    assert b['tracker_data'] is None
    memories = [{'title': 'First smile', 'photo_data': 'Yw==', 'favorite': True}]
    assert api_client.put(f"/api/v1/babies/{first['id']}/trackers/memories", json=memories).status_code == 200
    updated = api_client.patch(f"/api/v1/babies/{first['id']}", json={'photo_data': 'ZA==', 'name': 'Chris updated'})
    assert updated.status_code == 200
    reloaded = api_client.get(f"/api/v1/babies/{first['id']}").json()['data']
    assert reloaded['photo_data'] == 'ZA=='
    assert reloaded['tracker_data']['memories'] == memories
    assert reloaded['tracker_data']['feeding'] == entries
    assert api_client.get(f"/api/v1/babies/{second['id']}").json()['data']['tracker_data'] is None
    assert api_client.put(f'/api/v1/babies/{uuid4()}/trackers/feeding', json=entries).status_code == 404
    assert api_client.put(f"/api/v1/babies/{first['id']}/trackers/unknown", json=[]).status_code == 400
