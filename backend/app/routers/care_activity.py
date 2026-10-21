from datetime import datetime, timedelta, timezone
from typing import Annotated
from uuid import UUID
from fastapi import APIRouter, Depends, HTTPException, Query
from pydantic import BaseModel, Field
from sqlalchemy import select, func
from sqlalchemy.orm import load_only
from app.models import BabyShare
from sqlalchemy.ext.asyncio import AsyncSession
from app.auth.dependencies import get_current_user
from app.database.session import get_db_session
from app.models import User, Baby
from app.models.care_activity import CareActivity, CareDevice
from app.schemas.common import SuccessResponse
from app.services.baby_access import accessible_baby, access_role
from app.services.care_activity import add_activity, public_event

router = APIRouter(prefix='/api/v1/sharing', tags=['shared care'])
Current = Annotated[User, Depends(get_current_user)]
Session = Annotated[AsyncSession, Depends(get_db_session)]

class Message(BaseModel):
    text: str = Field(min_length=1, max_length=2000)
    client_id: UUID

class Device(BaseModel):
    token: str = Field(min_length=20, max_length=1024, pattern=r'^[A-Za-z0-9:_.-]+$')

@router.get('/conversations')
async def conversations(user: Current, session: Session):
    babies = (await session.execute(select(Baby).options(load_only(
        Baby.id, Baby.name, Baby.photo_data, Baby.owner_user_id)).where(
        (Baby.owner_user_id == user.id) | Baby.id.in_(select(BabyShare.baby_id).where(BabyShare.user_id == user.id))
    ))).scalars().all()
    ids = [baby.id for baby in babies]
    if not ids:
        return SuccessResponse(data=[])
    latest_ids = select(func.max(CareActivity.id)).where(
        CareActivity.baby_id.in_(ids), CareActivity.kind == 'chat', CareActivity.message.is_not(None)
    ).group_by(CareActivity.baby_id)
    latest = {e.baby_id: e for e in (await session.execute(select(CareActivity).where(CareActivity.id.in_(latest_ids)))).scalars()}
    counts = dict((await session.execute(select(BabyShare.baby_id, func.count(BabyShare.id)).where(
        BabyShare.baby_id.in_(ids), BabyShare.user_id.is_not(None)).group_by(BabyShare.baby_id))).all())
    babies.sort(key=lambda b: (-(latest[b.id].id if b.id in latest else 0), b.name.casefold()))
    return SuccessResponse(data=[dict(baby_id=str(b.id), baby_name=b.name,
        photo_data=b.photo_data, role=await access_role(session, b, user),
        members=1 + counts.get(b.id, 0),
        last_message=latest[b.id].message if b.id in latest else None,
        last_sender=latest[b.id].actor_name if b.id in latest else None,
        last_time=latest[b.id].created_at.isoformat() if b.id in latest else None) for b in babies])

@router.get('/babies/{baby_id}/status')
async def care_status(baby_id: UUID, user: Current, session: Session):
    baby = await accessible_baby(session, baby_id, user)
    latest = (await session.execute(select(func.max(CareActivity.id)).where(CareActivity.baby_id == baby_id))).scalar_one() or 0
    return SuccessResponse(data={'updated_at': baby.updated_at.isoformat(), 'latest_activity': latest,
                                 'role': await access_role(session, baby, user)})

@router.get('/babies/{baby_id}/activity')
async def activity(baby_id: UUID, user: Current, session: Session,
                   after: int | None = Query(default=None, ge=0), chat_only: bool = False):
    baby = await accessible_baby(session, baby_id, user)
    query = select(CareActivity).where(CareActivity.baby_id == baby_id)
    if chat_only:
        query = query.where(CareActivity.kind == 'chat')
    if after is not None:
        query = query.where(CareActivity.id > after).order_by(CareActivity.id)
    else:
        query = query.order_by(CareActivity.id.desc())
    events = (await session.execute(query.limit(100))).scalars().all()
    if after is None:
        events = list(reversed(events))
    return SuccessResponse(data={'baby_name': baby.name, 'role': await access_role(session, baby, user), 'can_chat': True,
        'events': [public_event(e, user, baby.owner_user_id == user.id) for e in events]})

@router.post('/babies/{baby_id}/messages', status_code=201)
async def message(baby_id: UUID, payload: Message, user: Current, session: Session):
    # Messaging is separate from permission to modify care records.
    baby = await accessible_baby(session, baby_id, user, lock=True)
    text = payload.text.strip()
    if not text:
        raise HTTPException(422, 'Enter a message.')
    previous = (await session.execute(select(CareActivity).where(
        CareActivity.baby_id == baby_id, CareActivity.actor_user_id == user.id,
        CareActivity.client_id == str(payload.client_id)))).scalar_one_or_none()
    if previous:
        return SuccessResponse(data=public_event(previous, user, baby.owner_user_id == user.id))
    count = (await session.execute(select(func.count()).select_from(CareActivity).where(
        CareActivity.actor_user_id == user.id, CareActivity.kind == 'chat',
        CareActivity.created_at >= datetime.now(timezone.utc) - timedelta(minutes=1)))).scalar_one()
    if count >= 20:
        raise HTTPException(429, 'Please wait a minute before sending more messages.')
    event = await add_activity(session, baby, user, 'chat', 'New care-team message', text, str(payload.client_id))
    await session.commit()
    return SuccessResponse(data=public_event(event, user, baby.owner_user_id == user.id))

@router.delete('/babies/{baby_id}/messages/{message_id}')
async def delete_message(baby_id: UUID, message_id: int, user: Current, session: Session):
    baby = await accessible_baby(session, baby_id, user, lock=True)
    event = await session.get(CareActivity, message_id)
    if event is None or event.baby_id != baby_id or event.kind != 'chat':
        raise HTTPException(404, 'Message not found.')
    if user.id not in {baby.owner_user_id, event.actor_user_id}:
        raise HTTPException(403, 'Only the sender or parent can remove this message.')
    event.message = None
    event.summary = 'Message removed'
    await session.commit()
    return SuccessResponse(data={'removed': True})

@router.put('/device')
async def register_device(payload: Device, user: Current, session: Session):
    device = await session.get(CareDevice, payload.token)
    if device is None:
        count = (await session.execute(select(func.count()).select_from(CareDevice).where(CareDevice.user_id == user.id))).scalar_one()
        if count >= 20:
            raise HTTPException(422, 'Device registration limit reached. Disable notifications on an old device first.')
        session.add(CareDevice(token=payload.token, user_id=user.id))
    elif device.user_id != user.id:
        device.registered_at = datetime.now(timezone.utc)
        device.user_id = user.id  # one device token must never belong to two accounts
    await session.commit()
    return SuccessResponse(data={'registered': True})

@router.delete('/device')
async def unregister_device(payload: Device, user: Current, session: Session):
    device = await session.get(CareDevice, payload.token)
    if device and device.user_id == user.id:
        await session.delete(device)
        await session.commit()
    return SuccessResponse(data={'removed': True})
