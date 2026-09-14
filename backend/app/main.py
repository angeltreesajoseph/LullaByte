"""LullaByte FastAPI application factory and ASGI entry point."""

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.core.logging import configure_logging
from app.core.settings import Settings, get_settings
from app.middleware.errors import register_exception_handlers
from app.middleware.request_context import request_context_middleware
from app.routers.health import router as health_router
from app.routers.account import router as account_router
from app.routers.babies import router as babies_router


def create_app(settings: Settings | None = None) -> FastAPI:
    """Build an application without initializing future external services."""

    runtime_settings = settings or get_settings()
    configure_logging(runtime_settings.log_level)

    application = FastAPI(
        title=runtime_settings.app_name,
        version=runtime_settings.app_version,
        debug=runtime_settings.debug,
        docs_url="/docs" if runtime_settings.environment != "production" else None,
        redoc_url=None,
        openapi_url=f"{runtime_settings.api_v1_prefix}/openapi.json",
    )
    application.state.settings = runtime_settings
    if settings is not None:
        # Keep factory-created applications fully isolated in tests and future
        # worker processes without mutating the process-wide settings cache.
        application.dependency_overrides[get_settings] = lambda: runtime_settings
    application.add_middleware(
        CORSMiddleware,
        allow_origins=runtime_settings.cors_allowed_origins,
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )
    application.middleware("http")(request_context_middleware)
    register_exception_handlers(application)
    application.include_router(health_router)
    application.include_router(account_router)
    application.include_router(babies_router)
    return application


app = create_app()
