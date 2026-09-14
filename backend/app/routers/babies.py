"""Ownership-scoped baby profile endpoints."""

from typing import Annotated
from uuid import UUID

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.auth.dependencies import get_current_user
from app.database.session import get_db_session
from app.models import Baby, User
from app.schemas.baby import BabyCreate, BabyResponse, BabyUpdate
from app.schemas.common import SuccessResponse

router = APIRouter(prefix="/api/v1/babies", tags=["babies"])


def _not_found() -> HTTPException:
    return HTTPException(status_code=404, detail="Baby profile not found.")


@router.post("", response_model=SuccessResponse, status_code=status.HTTP_201_CREATED)
async def create_baby(
    payload: BabyCreate,
    user: Annotated[User, Depends(get_current_user)],
    session: Annotated[AsyncSession, Depends(get_db_session)],
) -> SuccessResponse:
    baby = Baby(owner_user_id=user.id, **payload.model_dump())
    session.add(baby)
    await session.commit()
    await session.refresh(baby)
    return SuccessResponse(data=BabyResponse.model_validate(baby))


@router.get("", response_model=SuccessResponse)
async def list_babies(
    user: Annotated[User, Depends(get_current_user)],
    session: Annotated[AsyncSession, Depends(get_db_session)],
) -> SuccessResponse:
    result = await session.execute(
        select(Baby).where(Baby.owner_user_id == user.id).order_by(Baby.created_at)
    )
    return SuccessResponse(
        data=[BabyResponse.model_validate(baby) for baby in result.scalars().all()]
    )


async def _owned_baby(
    baby_id: UUID, user: User, session: AsyncSession
) -> Baby:
    result = await session.execute(
        select(Baby).where(Baby.id == baby_id, Baby.owner_user_id == user.id)
    )
    baby = result.scalar_one_or_none()
    if baby is None:
        raise _not_found()
    return baby


@router.get("/{baby_id}", response_model=SuccessResponse)
async def get_baby(
    baby_id: UUID,
    user: Annotated[User, Depends(get_current_user)],
    session: Annotated[AsyncSession, Depends(get_db_session)],
) -> SuccessResponse:
    baby = await _owned_baby(baby_id, user, session)
    return SuccessResponse(data=BabyResponse.model_validate(baby))


@router.patch("/{baby_id}", response_model=SuccessResponse)
async def update_baby(
    baby_id: UUID,
    payload: BabyUpdate,
    user: Annotated[User, Depends(get_current_user)],
    session: Annotated[AsyncSession, Depends(get_db_session)],
) -> SuccessResponse:
    baby = await _owned_baby(baby_id, user, session)
    for field, value in payload.model_dump(exclude_unset=True).items():
        setattr(baby, field, value)
    await session.commit()
    await session.refresh(baby)
    return SuccessResponse(data=BabyResponse.model_validate(baby))

