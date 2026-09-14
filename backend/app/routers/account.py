"""Authenticated account endpoints."""

from typing import Annotated

from fastapi import APIRouter, Depends

from app.auth.dependencies import get_current_user
from app.models import User
from app.schemas.account import UserResponse
from app.schemas.common import SuccessResponse

router = APIRouter(prefix="/api/v1/account", tags=["account"])


@router.get("/me", response_model=SuccessResponse)
async def get_me(user: Annotated[User, Depends(get_current_user)]) -> SuccessResponse:
    return SuccessResponse(data=UserResponse.model_validate(user))

