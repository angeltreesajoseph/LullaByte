import json
from types import SimpleNamespace
from uuid import uuid4
import httpx
import pytest
from fastapi import HTTPException
from fastapi.testclient import TestClient
from app.main import create_app
from app.core.settings import Settings
from app.auth.dependencies import get_current_user
from app.database.session import get_db_session
from app.routers import assistant
from app.services import gemini_assistant


def settings(**extra):
    return Settings(_env_file=None, environment='test', gemini_api_key='fake-test-key', **extra)


def mock_google(monkeypatch, status=200, payload=None):
    seen = []
    client = httpx.AsyncClient
    def handle(request):
        seen.append(request)
        return httpx.Response(status, json=payload or {'candidates': [{'finishReason':'STOP', 'content': {'parts':[{'text':'Test answer'}]}}]})
    monkeypatch.setattr(gemini_assistant.httpx, 'AsyncClient', lambda **kw: client(transport=httpx.MockTransport(handle), **kw))
    return seen


@pytest.mark.asyncio
async def test_request_uses_header_and_bounded_text_only(monkeypatch):
    seen = mock_google(monkeypatch)
    result = await gemini_assistant.generate(settings(), 'Question', [assistant.Turn(role='user',text='Prior question')])
    assert result == 'Test answer'
    assert seen[0].headers['x-goog-api-key'] == 'fake-test-key'
    assert 'fake-test-key' not in str(seen[0].url)
    body = json.loads(seen[0].content)
    assert set(body) == {'systemInstruction','contents','generationConfig'}
    assert body['contents'][-1]['parts'][0]['text'] == 'Question'
    assert body['generationConfig']['maxOutputTokens'] == 2048


@pytest.mark.asyncio
@pytest.mark.parametrize('status,expected', [(429,429),(403,503),(500,503)])
async def test_provider_errors_do_not_leak_secrets(monkeypatch,status,expected):
    mock_google(monkeypatch,status,{'error': {'message':'sensitive provider diagnostic'}})
    with pytest.raises(HTTPException) as error:
        await gemini_assistant.generate(settings(),'Question',[])
    assert error.value.status_code == expected
    assert 'sensitive' not in error.value.detail
    assert 'fake-test-key' not in error.value.detail


@pytest.mark.asyncio
async def test_missing_key_and_safety_block_are_explicit(monkeypatch):
    with pytest.raises(HTTPException) as error:
        await gemini_assistant.generate(Settings(_env_file=None,environment='test'),'Question',[])
    assert error.value.status_code == 503
    mock_google(monkeypatch,200,{'candidates':[{'finishReason':'SAFETY'}]})
    with pytest.raises(HTTPException) as error:
        await gemini_assistant.generate(settings(),'Question',[])
    assert error.value.status_code == 422


def client(monkeypatch):
    app = create_app(settings())
    app.dependency_overrides[get_current_user] = lambda: SimpleNamespace(id=uuid4())
    class ReadSession:
        async def rollback(self): pass
    async def session(): yield ReadSession()
    app.dependency_overrides[get_db_session] = session
    async def access(*args,**kwargs): return object()
    monkeypatch.setattr(assistant,'accessible_baby',access)
    return app


def test_route_requires_consent_validates_input_and_access(monkeypatch):
    app = client(monkeypatch)
    path=f'/api/v1/babies/{uuid4()}/assistant'
    calls=[]
    async def answer(*args): calls.append(args); return 'Hello'
    monkeypatch.setattr(assistant,'generate',answer)
    with TestClient(app) as api:
        assert api.post(path,json={'question':'Hello'}).status_code == 400
        assert api.post(path,json={'question':'x'*1001,'consent':True}).status_code == 422
        assert api.post(path,json={'question':'Hello','consent':True,'history':[{'role':'system','text':'bad'}]}).status_code == 422
        response=api.post(path,json={'question':'Hello','consent':True})
        assert response.json()['data']['answer'] == 'Hello'
        assert len(calls) == 1
        async def denied(*args,**kwargs): raise HTTPException(403,'No access')
        monkeypatch.setattr(assistant,'accessible_baby',denied)
        assert api.post(path,json={'question':'Hello','consent':True}).status_code == 403
        assert len(calls) == 1


def test_route_limits_requests_per_user(monkeypatch):
    app = client(monkeypatch)
    user=SimpleNamespace(id=uuid4())
    app.dependency_overrides[get_current_user]=lambda:user
    async def answer(*args): return 'Hello'
    monkeypatch.setattr(assistant,'generate',answer)
    with TestClient(app) as api:
        path=f'/api/v1/babies/{uuid4()}/assistant'
        for _ in range(10): assert api.post(path,json={'question':'Hello','consent':True}).status_code == 200
        assert api.post(path,json={'question':'Hello','consent':True}).status_code == 429
