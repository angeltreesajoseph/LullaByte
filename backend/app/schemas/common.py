"""Shared API response envelopes."""

from typing import Any

from pydantic import BaseModel, Field


class ErrorDetail(BaseModel):
    field: str | None = None
    message: str
    type: str | None = None


class ErrorBody(BaseModel):
    code: str
    message: str
    details: list[ErrorDetail] = Field(default_factory=list)
    request_id: str | None = None


class ErrorResponse(BaseModel):
    error: ErrorBody


class SuccessResponse(BaseModel):
    data: Any
    meta: dict[str, Any] = Field(default_factory=dict)

