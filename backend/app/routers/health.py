"""Operational health endpoint."""

from fastapi import APIRouter, Depends

from app.core.settings import Settings, get_settings
from app.schemas.health import HealthData, HealthResponse

router = APIRouter(tags=["health"])


@router.get("/health", response_model=HealthResponse, summary="Service health")
async def health(settings: Settings = Depends(get_settings)) -> HealthResponse:
    return HealthResponse(
        data=HealthData(
            service="lullabyte-api",
            version=settings.app_version,
            environment=settings.environment,
        )
    )

