"""Authenticated account endpoints."""

from typing import Annotated

from fastapi import APIRouter, Depends

from app.auth.dependencies import get_current_user
from app.models import User
from app.models.account_photo import AccountPhoto
from app.schemas.account import UserResponse, AccountPhotoUpdate
from app.database.session import get_db_session
from sqlalchemy.ext.asyncio import AsyncSession
from app.schemas.common import SuccessResponse

router = APIRouter(prefix="/api/v1/account", tags=["account"])


@router.get("/me", response_model=SuccessResponse)
async def get_me(user: Annotated[User, Depends(get_current_user)]) -> SuccessResponse:
    return SuccessResponse(data=UserResponse.model_validate(user))


@router.get('/me/photo', response_model=SuccessResponse)
async def get_photo(user: Annotated[User, Depends(get_current_user)],
                    session: Annotated[AsyncSession, Depends(get_db_session)]) -> SuccessResponse:
    photo = await session.get(AccountPhoto, user.id)
    return SuccessResponse(data={'photo_data': photo.photo_data if photo else None})


@router.put('/me/photo', response_model=SuccessResponse)
async def save_photo(payload: AccountPhotoUpdate,
                     user: Annotated[User, Depends(get_current_user)],
                     session: Annotated[AsyncSession, Depends(get_db_session)]) -> SuccessResponse:
    # No caller-supplied user ID: a shared-care member can only edit their own avatar.
    photo = await session.get(AccountPhoto, user.id)
    if payload.photo_data is None:
        if photo is not None:
            await session.delete(photo)
    elif photo is None:
        session.add(AccountPhoto(user_id=user.id, photo_data=payload.photo_data))
    else:
        photo.photo_data = payload.photo_data
    await session.commit()
    return SuccessResponse(data={'photo_data': payload.photo_data})

