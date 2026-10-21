from uuid import uuid4
from test_sharing_api import sharing_client  # noqa: F401

def test_managers_get_care_alerts_viewers_only_chat_and_never_own_actions(sharing_client):
    c, state = sharing_client
    baby = c.post('/api/v1/babies', json={'name': 'Anna'}).json()['data']['id']
    manager = c.post(f'/api/v1/sharing/babies/{baby}', json={'email':'care@example.com', 'role':'caregiver'}).json()['data']['id']
    viewer = c.post(f'/api/v1/sharing/babies/{baby}', json={'email':'stranger@example.com', 'role':'viewer'}).json()['data']['id']
    state['person'] = 1
    c.post(f'/api/v1/sharing/{manager}/accept')
    state['person'] = 2
    c.post(f'/api/v1/sharing/{viewer}/accept')
    state['person'] = 0
    rev = c.get(f'/api/v1/babies/{baby}').json()['data']['tracker_revisions']['feeding']
    assert c.put(f'/api/v1/babies/{baby}/trackers/feeding', json=[{'type':'bottle'}], headers={'X-Care-Revision':rev}).status_code == 200
    assert c.get('/api/v1/sharing/alerts').json()['data']['unread_count'] == 0
    state['person'] = 1
    assert c.get('/api/v1/sharing/alerts').json()['data']['unread_count'] == 1
    state['person'] = 2
    assert c.get('/api/v1/sharing/alerts').json()['data']['unread_count'] == 0
    assert c.post(f'/api/v1/sharing/babies/{baby}/messages',json={'text':'Checking in','client_id':str(uuid4())}).status_code == 201
    assert c.get('/api/v1/sharing/alerts').json()['data']['unread_count'] == 0
    state['person'] = 0
    assert c.get('/api/v1/sharing/alerts').json()['data']['unread_count'] == 1
    c.patch(f'/api/v1/sharing/{manager}',json={'role':'viewer'})
    state['person'] = 1
    data = c.get('/api/v1/sharing/alerts').json()['data']
    assert data['unread_count'] == 1
    assert all(row['kind'] == 'chat' for row in data['items'])

def test_alerts_persist_without_push_and_are_account_and_access_scoped(sharing_client):
    c, state = sharing_client
    baby = c.post('/api/v1/babies', json={'name': 'Anna'}).json()['data']['id']
    sid = c.post(f'/api/v1/sharing/babies/{baby}', json={'email':'care@example.com', 'role':'caregiver'}).json()['data']['id']
    state['person'] = 1
    c.post(f'/api/v1/sharing/{sid}/accept')
    rev = c.get(f'/api/v1/babies/{baby}').json()['data']['tracker_revisions']['feeding']
    assert c.put(f'/api/v1/babies/{baby}/trackers/feeding', json=[{'type':'bottle'}],
        headers={'X-Care-Revision':rev}).status_code == 200
    assert c.get('/api/v1/sharing/alerts').json()['data']['unread_count'] == 0
    state['person'] = 0
    data = c.get('/api/v1/sharing/alerts').json()['data']
    assert data['unread_count'] == 1 and data['items'][0]['baby_name'] == 'Anna'
    alert = data['items'][0]['id']
    activity = data['items'][0]['activity_id']
    assert c.get(f'/api/v1/sharing/alerts?activity_id={activity}').json()['data']['target']['id'] == alert
    assert c.post(f'/api/v1/sharing/alerts/{alert}/read').status_code == 200
    assert c.get('/api/v1/sharing/alerts').json()['data']['items'][0]['read'] is True
    assert c.get('/api/v1/sharing/alerts').json()['data']['unread_count'] == 0
    # Chat alerts go to accepted members, independently of device registration.
    c.post(f'/api/v1/sharing/babies/{baby}/messages',json={'text':'Hello','client_id':str(uuid4())})
    state['person'] = 1
    data = c.get('/api/v1/sharing/alerts').json()['data']
    assert data['unread_count'] == 1 and data['items'][0]['kind'] == 'chat'
    own_alert = data['items'][0]['id']
    assert c.post(f'/api/v1/sharing/alerts/{alert}/read').status_code == 404
    assert c.post('/api/v1/sharing/alerts/read',json={'through_id':own_alert}).status_code == 200
    assert c.get('/api/v1/sharing/alerts').json()['data']['unread_count'] == 0
    state['person'] = 2
    assert c.get('/api/v1/sharing/alerts').json()['data']['items'] == []
    assert c.get(f'/api/v1/sharing/alerts?activity_id={activity}').json()['data']['target'] is None
    assert c.get('/api/v1/sharing/alerts').json()['data']['babies'] == []
    assert c.post(f'/api/v1/sharing/alerts/{own_alert}/read').status_code == 404
    state['person'] = 0
    c.delete(f'/api/v1/sharing/{sid}')
    state['person'] = 1
    assert c.get('/api/v1/sharing/alerts').json()['data']['items'] == []
    assert c.post(f'/api/v1/sharing/alerts/{own_alert}/read').status_code == 404

