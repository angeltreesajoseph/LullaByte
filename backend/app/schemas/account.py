"""Account response schemas."""

from uuid import UUID

import base64
import binascii
from pydantic import BaseModel, ConfigDict, Field, field_validator


class UserResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: UUID
    firebase_uid: str
    email: str | None
    display_name: str | None
    is_active: bool


class AccountPhotoUpdate(BaseModel):
    model_config = ConfigDict(extra='forbid')
    photo_data: str | None = Field(max_length=500000)

    @field_validator('photo_data')
    @classmethod
    def validate_photo(cls, value):
        if value is None:
            return value
        try:
            header, payload = value.split(',', 1)
            data = base64.b64decode(payload, validate=True)
        except (ValueError, binascii.Error):
            raise ValueError('Choose a valid JPEG or PNG photo.') from None
        if header == 'data:image/png;base64' and data.startswith(b'\x89PNG\r\n\x1a\n'):
            return value
        if header == 'data:image/jpeg;base64' and data.startswith(b'\xff\xd8\xff'):
            return value
        raise ValueError('Choose a valid JPEG or PNG photo.')

