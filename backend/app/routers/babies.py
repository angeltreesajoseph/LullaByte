"""Ownership-scoped baby profile endpoints."""

from typing import Annotated
from uuid import UUID

from fastapi import APIRouter, Body, Depends, HTTPException, status
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


@router.put('/{baby_id}/trackers/{kind}', response_model=SuccessResponse)
async def save_tracker(
    baby_id: UUID,
    kind: str,
    entries: Annotated[list[dict], Body(max_length=5000)],
    user: Annotated[User, Depends(get_current_user)],
    session: Annotated[AsyncSession, Depends(get_db_session)],
) -> SuccessResponse:
    if kind not in {'feeding', 'sleep', 'diaper', 'growth', 'milestones', 'memories', 'cry'}:
        raise HTTPException(status_code=400, detail='Unknown tracker.')
    if kind == 'cry':
        import base64
        import binascii
        if len(entries) > 20:
            raise HTTPException(status_code=422, detail='Maximum 20 recordings per baby.')
        for entry in entries:
            audio = entry.get('audio_data')
            if not isinstance(audio, str) or len(audio) > 400000:
                raise HTTPException(status_code=422, detail='Audio exceeds recording size limit.')
            try:
                if not base64.b64decode(audio, validate=True):
                    raise ValueError('Empty audio')
            except (ValueError, binascii.Error):
                raise HTTPException(status_code=422, detail='Invalid audio data.')
            if entry.get('format') not in {'wav', 'mp3', 'm4a'}:
                raise HTTPException(status_code=422, detail='Unsupported audio format.')
            # No validated inference model is deployed. Never accept client predictions.
            entry['result'] = 'Analysis unavailable'
            entry['confidence'] = None
    result = await session.execute(select(Baby).where(
        Baby.id == baby_id, Baby.owner_user_id == user.id
    ).with_for_update())
    baby = result.scalar_one_or_none()
    if baby is None:
        raise _not_found()
    baby.tracker_data = {**(baby.tracker_data or {}), kind: entries}
    await session.commit()
    return SuccessResponse(data=entries)

