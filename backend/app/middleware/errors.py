"""Standard API exceptions and exception-to-envelope translation."""

import logging
from typing import Any

from fastapi import FastAPI, Request
from fastapi.exceptions import RequestValidationError
from fastapi.responses import JSONResponse
from starlette.exceptions import HTTPException as StarletteHTTPException

logger = logging.getLogger("lullabyte.errors")


class ApiError(Exception):
    """Expected application error with a stable client-facing code."""

    def __init__(
        self,
        *,
        status_code: int,
        code: str,
        message: str,
        details: list[dict[str, Any]] | None = None,
    ) -> None:
        super().__init__(message)
        self.status_code = status_code
        self.code = code
        self.message = message
        self.details = details or []


def _request_id(request: Request) -> str | None:
    return getattr(request.state, "request_id", None)


def _error_response(
    request: Request,
    *,
    status_code: int,
    code: str,
    message: str,
    details: list[dict[str, Any]] | None = None,
    headers: dict[str, str] | None = None,
) -> JSONResponse:
    request_id = _request_id(request)
    return JSONResponse(
        status_code=status_code,
        headers={
            **(headers or {}),
            **({"X-Request-ID": request_id} if request_id else {}),
        }
        or None,
        content={
            "error": {
                "code": code,
                "message": message,
                "details": details or [],
                "request_id": request_id,
            }
        },
    )


def register_exception_handlers(app: FastAPI) -> None:
    @app.exception_handler(ApiError)
    async def api_error_handler(request: Request, error: ApiError) -> JSONResponse:
        return _error_response(
            request,
            status_code=error.status_code,
            code=error.code,
            message=error.message,
            details=error.details,
        )

    @app.exception_handler(RequestValidationError)
    async def validation_error_handler(
        request: Request, error: RequestValidationError
    ) -> JSONResponse:
        details = [
            {
                "field": ".".join(str(part) for part in item["loc"]),
                "message": item["msg"],
                "type": item["type"],
            }
            for item in error.errors()
        ]
        return _error_response(
            request,
            status_code=422,
            code="VALIDATION_FAILED",
            message="The request contains invalid data.",
            details=details,
        )

    @app.exception_handler(StarletteHTTPException)
    async def http_error_handler(
        request: Request, error: StarletteHTTPException
    ) -> JSONResponse:
        code = "RESOURCE_NOT_FOUND" if error.status_code == 404 else "HTTP_ERROR"
        message = "The requested resource was not found." if error.status_code == 404 else str(error.detail)
        return _error_response(
            request,
            status_code=error.status_code,
            code=code,
            message=message,
            headers=error.headers,
        )

    @app.exception_handler(Exception)
    async def unhandled_error_handler(request: Request, error: Exception) -> JSONResponse:
        logger.exception("Unhandled request error request_id=%s", _request_id(request), exc_info=error)
        return _error_response(
            request,
            status_code=500,
            code="INTERNAL_ERROR",
            message="An unexpected server error occurred.",
        )
