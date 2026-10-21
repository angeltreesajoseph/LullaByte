from uuid import uuid4
from test_sharing_api import sharing_client  # noqa: F401

def test_conversations_only_include_owned_or_accepted_babies(sharing_client):
    c, state = sharing_client
    one = c.post('/api/v1/babies', json={'name': 'Anna'}).json()['data']['id']
    two = c.post('/api/v1/babies', json={'name': 'Ben'}).json()['data']['id']
    assert {r['baby_id'] for r in c.get('/api/v1/sharing/conversations').json()['data']} == {one, two}
    sid = c.post(f'/api/v1/sharing/babies/{one}', json={'email': 'care@example.com', 'role': 'viewer'}).json()['data']['id']
    c.post(f'/api/v1/sharing/babies/{two}/messages', json={'text': 'Private twin message', 'client_id': str(uuid4())})
    state['person'] = 1
    assert c.get('/api/v1/sharing/conversations').json()['data'] == []
    assert c.post(f'/api/v1/sharing/{sid}/accept').status_code == 200
    assert c.post(f'/api/v1/sharing/babies/{one}/messages', json={'text': 'Grandparent checking in', 'client_id': str(uuid4())}).status_code == 201
    rows = c.get('/api/v1/sharing/conversations').json()['data']
    assert len(rows) == 1 and rows[0]['baby_id'] == one
    assert rows[0]['last_message'] == 'Grandparent checking in'
    assert rows[0]['members'] == 2 and rows[0]['role'] == 'viewer'
    assert c.put(f'/api/v1/babies/{one}/trackers/feeding', json=[]).status_code == 403
    messages = c.get(f'/api/v1/sharing/babies/{one}/activity?chat_only=true').json()['data']
    assert messages['can_chat'] is True
    assert messages['events'][-1]['mine'] is True
    state['person'] = 0
    assert c.delete(f'/api/v1/sharing/{sid}').status_code == 200
    state['person'] = 1
    assert c.get('/api/v1/sharing/conversations').json()['data'] == []
    assert c.post(f'/api/v1/sharing/babies/{one}/messages', json={'text': 'Revoked', 'client_id': str(uuid4())}).status_code == 404
