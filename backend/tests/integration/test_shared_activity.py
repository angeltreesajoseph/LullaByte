from uuid import uuid4
from test_sharing_api import sharing_client  # noqa: F401
import pytest
from sqlalchemy import select
from app.models.care_activity import CareDevice, CareDelivery
from app.services.care_activity import deliver_pending
from types import SimpleNamespace

def test_activity_chat_permissions_and_retry(sharing_client):
    c, state = sharing_client
    one = c.post('/api/v1/babies', json={'name': 'One'}).json()['data']['id']
    two = c.post('/api/v1/babies', json={'name': 'Two'}).json()['data']['id']
    sid = c.post(f'/api/v1/sharing/babies/{one}', json={'email': 'care@example.com', 'role': 'caregiver'}).json()['data']['id']
    state['person'] = 1
    assert c.post(f'/api/v1/sharing/{sid}/accept').status_code == 200
    revision = c.get(f'/api/v1/babies/{one}').json()['data']['tracker_revisions']['feeding']
    endpoint = f'/api/v1/babies/{one}/trackers/feeding'
    assert c.put(endpoint, json=[]).status_code == 409
    assert c.put(endpoint, json=[{'type': 'bottle'}], headers={'X-Care-Revision': revision}).status_code == 200
    assert c.get(f'/api/v1/sharing/babies/{two}/activity').status_code == 404
    msg = {'text': 'Fed at noon', 'client_id': str(uuid4())}
    url = f'/api/v1/sharing/babies/{one}/messages'
    first = c.post(url, json=msg)
    assert first.status_code == 201
    mid = first.json()['data']['id']
    assert c.post(url, json=msg).json()['data']['id'] == mid
    assert c.post(url, json={'text': '  ', 'client_id': str(uuid4())}).status_code == 422
    state['person'] = 0
    events = c.get(f'/api/v1/sharing/babies/{one}/activity').json()['data']['events']
    assert [e['kind'] for e in events] == ['feeding', 'chat']
    assert events[-1]['message'] == 'Fed at noon'
    assert c.get(f'/api/v1/sharing/babies/{one}/status').json()['data']['latest_activity'] == mid
    assert c.delete(f'{url}/{mid}').status_code == 200
    assert c.get(f'/api/v1/sharing/babies/{one}/activity').json()['data']['events'][-1]['message'] is None
    assert c.patch(f'/api/v1/sharing/{sid}', json={'role': 'viewer'}).status_code == 200
    state['person'] = 1
    assert c.post(url, json={'text': 'Viewer message', 'client_id': str(uuid4())}).status_code == 201
    assert c.put(endpoint, json=[]).status_code == 403
    assert c.get(f'/api/v1/sharing/babies/{one}/activity').status_code == 200
    state['person'] = 0
    assert c.delete(f'/api/v1/sharing/{sid}').status_code == 200
    state['person'] = 1
    assert c.get(f'/api/v1/sharing/babies/{one}/activity').status_code == 404
    assert c.post(url, json={'text': 'Revoked message', 'client_id': str(uuid4())}).status_code == 404

def test_invitation_page_has_no_baby_data_and_device_auth(sharing_client):
    c, state = sharing_client
    page = c.get(f'/join/{uuid4()}')
    assert page.status_code == 200
    assert 'lullabyte://app/join?invitation=' in page.text
    assert page.headers['Referrer-Policy'] == 'no-referrer'
    assert 'no-store' in page.headers['Cache-Control']
    token = 'some_fcm_device_token_1234567890'
    assert c.put('/api/v1/sharing/device', json={'token': token}).status_code == 200
    state['person'] = 1
    assert c.request('DELETE', '/api/v1/sharing/device', json={'token': token}).status_code == 200

@pytest.mark.asyncio
async def test_push_targets_parent_and_revoked_members_do_not_receive_queued_chat(sharing_client, monkeypatch):
    c, state = sharing_client
    sent = []
    def fake_push(tokens, baby_id, event_id):
        sent.append((tokens, str(baby_id), event_id))
        return SimpleNamespace(failure_count=0, responses=[SimpleNamespace(success=True) for _ in tokens])
    monkeypatch.setattr('app.services.care_activity.send_push', fake_push)
    one = c.post('/api/v1/babies', json={'name': 'One'}).json()['data']['id']
    parent_token = 'parent_phone_token_1234567890'
    caregiver_token = 'caregiver_phone_token_1234567890'
    assert c.put('/api/v1/sharing/device', json={'token': parent_token}).status_code == 200
    sid = c.post(f'/api/v1/sharing/babies/{one}', json={'email': 'care@example.com', 'role': 'caregiver'}).json()['data']['id']
    state['person'] = 1
    c.post(f'/api/v1/sharing/{sid}/accept')
    c.put('/api/v1/sharing/device', json={'token': caregiver_token})
    rev = c.get(f'/api/v1/babies/{one}').json()['data']['tracker_revisions']['sleep']
    assert c.put(f'/api/v1/babies/{one}/trackers/sleep', json=[{'status': 'sleeping'}], headers={'X-Care-Revision': rev}).status_code == 200
    async with state['factory']() as session:
        await deliver_pending(session)
    assert len(sent) == 1 and sent[0][0] == [parent_token] and sent[0][1] == one
    state['person'] = 0
    assert c.post(f'/api/v1/sharing/babies/{one}/messages', json={'text': 'Update?', 'client_id': str(uuid4())}).status_code == 201
    c.delete(f'/api/v1/sharing/{sid}')
    async with state['factory']() as session:
        await deliver_pending(session)
    assert len(sent) == 1

@pytest.mark.asyncio
async def test_device_unregistration_is_account_scoped(sharing_client):
    c, state = sharing_client
    token = 'device_private_token_1234567890'
    c.put('/api/v1/sharing/device', json={'token': token})
    state['person'] = 1
    c.request('DELETE', '/api/v1/sharing/device', json={'token': token})
    async with state['factory']() as session:
        assert (await session.get(CareDevice, token)) is not None
    state['person'] = 0
    c.request('DELETE', '/api/v1/sharing/device', json={'token': token})
    async with state['factory']() as session:
        assert (await session.get(CareDevice, token)) is None
