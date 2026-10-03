"""Baby profile request and response schemas."""

from datetime import date, datetime
from decimal import Decimal
from uuid import UUID

from pydantic import BaseModel, ConfigDict, Field


class BabyCreate(BaseModel):
    photo_data: str | None = Field(default=None, max_length=500000)
    name: str = Field(min_length=1, max_length=120)
    birth_date: date | None = None
    gender: str | None = Field(default=None, max_length=32)
    birth_weight_kg: Decimal | None = Field(default=None, ge=0, le=100)
    birth_length_cm: Decimal | None = Field(default=None, ge=0, le=250)
    blood_group: str | None = Field(default=None, max_length=16)
    allergies: str | None = Field(default=None, max_length=500)
    pediatrician: str | None = Field(default=None, max_length=160)
    hospital: str | None = Field(default=None, max_length=160)
    head_circumference_cm: Decimal | None = Field(default=None, ge=0, le=100)


class BabyUpdate(BaseModel):
    photo_data: str | None = Field(default=None, max_length=500000)
    name: str | None = Field(default=None, min_length=1, max_length=120)
    birth_date: date | None = None
    gender: str | None = Field(default=None, max_length=32)
    birth_weight_kg: Decimal | None = Field(default=None, ge=0, le=100)
    birth_length_cm: Decimal | None = Field(default=None, ge=0, le=250)
    blood_group: str | None = Field(default=None, max_length=16)
    allergies: str | None = Field(default=None, max_length=500)
    pediatrician: str | None = Field(default=None, max_length=160)
    hospital: str | None = Field(default=None, max_length=160)
    head_circumference_cm: Decimal | None = Field(default=None, ge=0, le=100)


class BabyResponse(BaseModel):
    tracker_data: dict | None
    photo_data: str | None
    model_config = ConfigDict(from_attributes=True)

    id: UUID
    owner_user_id: UUID
    name: str
    birth_date: date | None
    gender: str | None
    birth_weight_kg: Decimal | None
    birth_length_cm: Decimal | None
    blood_group: str | None
    allergies: str | None
    pediatrician: str | None
    hospital: str | None
    head_circumference_cm: Decimal | None
    created_at: datetime
    updated_at: datetime
