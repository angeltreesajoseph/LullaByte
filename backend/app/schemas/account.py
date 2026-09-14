"""Account response schemas."""

from uuid import UUID

from pydantic import BaseModel, ConfigDict


class UserResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: UUID
    firebase_uid: str
    email: str | None
    display_name: str | None
    is_active: bool

