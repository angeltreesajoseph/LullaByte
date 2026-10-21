"""Ownership-scoped baby profile endpoints."""

from typing import Annotated
from uuid import UUID

from fastapi import APIRouter, Body, Depends, HTTPException, status, Header, Response
from pydantic import BaseModel, Field
from starlette.concurrency import run_in_threadpool
from datetime import datetime, timezone
import base64
import binascii
import hashlib
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.auth.dependencies import get_current_user
from app.database.session import get_db_session
from app.models import Baby, User, BabyShare
from app.services.baby_access import accessible_baby, access_role, revisions, tracker_revision
from app.services.care_activity import add_activity
from app.schemas.baby import BabyCreate, BabyResponse, BabyUpdate
from app.schemas.common import SuccessResponse

router = APIRouter(prefix="/api/v1/babies", tags=["babies"])


class CryAnalysisRequest(BaseModel):
    audio_data: str = Field(min_length=1, max_length=2800000)
    format: str
    accept_experimental: bool = False


@router.post('/{baby_id}/cry/analyze', response_model=SuccessResponse)
async def analyze_cry(
    baby_id: UUID,
    payload: CryAnalysisRequest,
    user: Annotated[User, Depends(get_current_user)],
    session: Annotated[AsyncSession, Depends(get_db_session)],
) -> SuccessResponse:
    await accessible_baby(session, baby_id, user, write=True)
    if not payload.accept_experimental:
        raise HTTPException(status_code=400, detail='Experimental analysis consent is required.')
    if payload.format not in {'wav', 'mp3', 'm4a', 'ogg'}:
        raise HTTPException(status_code=422, detail='Unsupported audio format.')
    try:
        audio = base64.b64decode(payload.audio_data, validate=True)
        if not audio or len(audio) > 2000000:
            raise ValueError('Recording must be non-empty and under 2 MB.')
    except (ValueError, binascii.Error):
        raise HTTPException(status_code=422, detail='Invalid or oversized audio.')
    from app.services.cry_inference import analyze
    try:
        analysis = await run_in_threadpool(analyze, audio)
    except BlockingIOError:
        raise HTTPException(status_code=429, detail='Analyzer busy. Retry shortly.')
    except ValueError as error:
        raise HTTPException(status_code=422, detail=str(error))
    except Exception:
        raise HTTPException(status_code=503, detail='Experimental model unavailable. Check server setup.')
    baby = await accessible_baby(session, baby_id, user, write=True, lock=True)
    history = list((baby.tracker_data or {}).get('cry', []))
    if len(history) >= 20 or sum(len(item.get('audio_data', '')) for item in history) + len(payload.audio_data) > 11000000:
        raise HTTPException(status_code=422, detail='History is full. Delete older recordings first.')
    entry = {'audio_data': payload.audio_data, 'format': payload.format,
             'time': datetime.now(timezone.utc).isoformat(),
             'audio_sha256': hashlib.sha256(audio).hexdigest(), **analysis}
    history.insert(0, entry)
    baby.tracker_data = {**(baby.tracker_data or {}), 'cry': history}
    await add_activity(session, baby, user, 'cry', 'New cry recording added')
    await session.commit()
    return SuccessResponse(data={'entry': entry, 'history': history})


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
        select(Baby).where((Baby.owner_user_id == user.id) | Baby.id.in_(
            select(BabyShare.baby_id).where(BabyShare.user_id == user.id)
        )).order_by(Baby.created_at)
    )
    return SuccessResponse(
        data=[{**BabyResponse.model_validate(baby).model_dump(),
               'access_role': await access_role(session, baby, user),
               'tracker_revisions': revisions(baby)} for baby in result.scalars().all()]
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
    baby = await accessible_baby(session, baby_id, user)
    return SuccessResponse(data={**BabyResponse.model_validate(baby).model_dump(),
                                 'access_role': await access_role(session, baby, user),
                                 'tracker_revisions': revisions(baby)})


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
    response: Response,
    x_care_revision: Annotated[str | None, Header()] = None,
) -> SuccessResponse:
    if kind not in {'feeding', 'sleep', 'diaper', 'growth', 'milestones', 'memories', 'cry', 'vaccinations'}:
        raise HTTPException(status_code=400, detail='Unknown tracker.')
    if kind == 'cry':
        import base64
        import binascii
        if len(entries) > 20:
            raise HTTPException(status_code=422, detail='Maximum 20 recordings per baby.')
        if sum(len(item.get('audio_data', '')) for item in entries if isinstance(item.get('audio_data'), str)) > 11000000:
            raise HTTPException(status_code=422, detail='History storage limit reached. Delete older recordings.')
        for entry in entries:
            audio = entry.get('audio_data')
            if not isinstance(audio, str) or len(audio) > 2800000:
                raise HTTPException(status_code=422, detail='Audio exceeds recording size limit.')
            try:
                if not base64.b64decode(audio, validate=True):
                    raise ValueError('Empty audio')
            except (ValueError, binascii.Error):
                raise HTTPException(status_code=422, detail='Invalid audio data.')
            if entry.get('format') not in {'wav', 'mp3', 'm4a', 'ogg'}:
                raise HTTPException(status_code=422, detail='Unsupported audio format.')
            # No validated inference model is deployed. Never accept client predictions.
            entry['result'] = 'Analysis unavailable'
            entry['confidence'] = None
    baby = await accessible_baby(session, baby_id, user, write=True, lock=True)
    current_revision = tracker_revision((baby.tracker_data or {}).get(kind, []))
    shared = (await session.execute(select(BabyShare.id).where(
        BabyShare.baby_id == baby_id, BabyShare.user_id.is_not(None)).limit(1))).scalar_one_or_none()
    if (x_care_revision is not None and x_care_revision != current_revision) or (shared is not None and x_care_revision is None):
        raise HTTPException(409, 'Records changed on another device. Refresh this tracker before saving. Shared care requires the latest app version.')
    if kind == 'vaccinations':
        from app.schemas.vaccination import VaccinationRecord
        from pydantic import ValidationError
        if len(entries) > 200:
            raise HTTPException(status_code=422, detail='Maximum 200 vaccination entries.')
        try:
            parsed = [VaccinationRecord.model_validate(entry) for entry in entries]
        except ValidationError:
            raise HTTPException(status_code=422, detail='Invalid vaccination entry or received date.')
        if len({entry.id for entry in parsed}) != len(parsed):
            raise HTTPException(status_code=422, detail='Duplicate vaccination identifiers.')
        if baby.birth_date and any(entry.received_date and entry.received_date.date() < baby.birth_date for entry in parsed):
            raise HTTPException(status_code=422, detail='Received date cannot be before birth.')
        entries = [entry.model_dump(mode='json') for entry in parsed]
    if kind == 'cry':
        # Preserve server-generated analysis on playback/deletion updates.
        previous = {(item.get('audio_data'), item.get('time')): item
                    for item in (baby.tracker_data or {}).get('cry', [])}
        entries = [previous.get((item.get('audio_data'), item.get('time')), {
            'audio_data': item['audio_data'], 'format': item['format'],
            'time': item.get('time'), 'result': 'Analysis unavailable', 'confidence': None,
        }) for item in entries]
    previous_entries = (baby.tracker_data or {}).get(kind, [])
    if previous_entries != entries:
        verb = 'Added' if len(entries) > len(previous_entries) else 'Removed' if len(entries) < len(previous_entries) else 'Updated'
        await add_activity(session, baby, user, kind, f'{verb} {kind} records')
    baby.tracker_data = {**(baby.tracker_data or {}), kind: entries}
    await session.commit()
    response.headers['X-Care-Revision'] = tracker_revision(entries)
    return SuccessResponse(data=entries)

