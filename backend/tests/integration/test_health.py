"""Application-boundary tests that require no external services."""

from fastapi.testclient import TestClient


def test_health_returns_versioned_success_envelope(client: TestClient) -> None:
    response = client.get("/health")

    assert response.status_code == 200
    assert response.json() == {
        "data": {
            "status": "ok",
            "service": "lullabyte-api",
            "version": "0.1.0",
            "environment": "test",
        },
        "meta": {},
    }
    assert response.headers["X-Request-ID"]


def test_caller_request_id_is_preserved(client: TestClient) -> None:
    response = client.get("/health", headers={"X-Request-ID": "test-request-123"})
    assert response.headers["X-Request-ID"] == "test-request-123"


def test_unknown_route_uses_standard_error_envelope(client: TestClient) -> None:
    response = client.get("/does-not-exist")

    assert response.status_code == 404
    payload = response.json()
    assert payload["error"]["code"] == "RESOURCE_NOT_FOUND"
    assert payload["error"]["details"] == []
    assert payload["error"]["request_id"] == response.headers["X-Request-ID"]


def test_openapi_is_versioned(client: TestClient) -> None:
    assert client.get("/api/v1/openapi.json").status_code == 200

