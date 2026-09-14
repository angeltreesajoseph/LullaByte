"""Standard error-envelope integration tests."""

from fastapi import Body
from fastapi.testclient import TestClient
from pydantic import BaseModel, Field

from app.core.settings import Settings
from app.main import create_app
from app.middleware.errors import ApiError


class _ExamplePayload(BaseModel):
    name: str = Field(min_length=2)


def _client_with_test_routes() -> TestClient:
    application = create_app(
        Settings(environment="test", debug=False, log_level="CRITICAL")
    )

    @application.post("/_test/validate")
    async def validate(payload: _ExamplePayload = Body()) -> dict[str, str]:
        return {"name": payload.name}

    @application.get("/_test/expected-error")
    async def expected_error() -> None:
        raise ApiError(
            status_code=409,
            code="TEST_CONFLICT",
            message="A test conflict occurred.",
            details=[{"field": "record_id", "message": "Already exists."}],
        )

    @application.get("/_test/unhandled-error")
    async def unhandled_error() -> None:
        raise RuntimeError("sensitive internal detail")

    return TestClient(application, raise_server_exceptions=False)


def test_validation_errors_use_standard_envelope() -> None:
    with _client_with_test_routes() as client:
        response = client.post("/_test/validate", json={"name": ""})

    assert response.status_code == 422
    payload = response.json()["error"]
    assert payload["code"] == "VALIDATION_FAILED"
    assert payload["details"][0]["field"] == "body.name"
    assert payload["request_id"] == response.headers["X-Request-ID"]


def test_expected_api_error_preserves_code_and_details() -> None:
    with _client_with_test_routes() as client:
        response = client.get("/_test/expected-error")

    assert response.status_code == 409
    payload = response.json()["error"]
    assert payload["code"] == "TEST_CONFLICT"
    assert payload["details"] == [
        {"field": "record_id", "message": "Already exists."}
    ]


def test_unhandled_error_does_not_leak_internal_detail() -> None:
    with _client_with_test_routes() as client:
        response = client.get("/_test/unhandled-error")

    assert response.status_code == 500
    payload = response.json()["error"]
    assert payload["code"] == "INTERNAL_ERROR"
    assert "sensitive internal detail" not in response.text
    assert payload["request_id"] == response.headers["X-Request-ID"]
