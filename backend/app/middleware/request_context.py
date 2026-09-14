"""Request correlation and access logging middleware."""

import logging
import time
from uuid import uuid4

from fastapi import Request, Response

logger = logging.getLogger("lullabyte.http")


async def request_context_middleware(request: Request, call_next) -> Response:
    """Attach a server-controlled request ID and emit one completion log."""

    request_id = request.headers.get("X-Request-ID", "").strip() or str(uuid4())
    request.state.request_id = request_id
    started = time.perf_counter()

    response = await call_next(request)
    response.headers["X-Request-ID"] = request_id
    elapsed_ms = (time.perf_counter() - started) * 1000
    logger.info(
        "%s %s -> %s %.2fms request_id=%s",
        request.method,
        request.url.path,
        response.status_code,
        elapsed_ms,
        request_id,
    )
    return response

