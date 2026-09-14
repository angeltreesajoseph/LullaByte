"""Health-check schemas."""

from typing import Literal

from pydantic import BaseModel, Field


class HealthData(BaseModel):
    status: Literal["ok"] = "ok"
    service: str
    version: str
    environment: str


class HealthResponse(BaseModel):
    data: HealthData
    meta: dict[str, object] = Field(default_factory=dict)
