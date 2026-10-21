from datetime import datetime, timedelta, timezone
from typing import Annotated
from uuid import UUID
from fastapi import APIRouter, Depends, HTTPException, Query
from pydantic import BaseModel, Field
from sqlalchemy import select, func
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

@router.get('/babies/{baby_id}/status')
async def care_status(baby_id: UUID, user: Current, session: Session):
    baby = await accessible_baby(session, baby_id, user)
    latest = (await session.execute(select(func.max(CareActivity.id)).where(CareActivity.baby_id == baby_id))).scalar_one() or 0
    return SuccessResponse(data={'updated_at': baby.updated_at.isoformat(), 'latest_activity': latest,
                                 'role': await access_role(session, baby, user)})

@router.get('/babies/{baby_id}/activity')
async def activity(baby_id: UUID, user: Current, session: Session,
                   after: int | None = Query(default=None, ge=0)):
    baby = await accessible_baby(session, baby_id, user)
    query = select(CareActivity).where(CareActivity.baby_id == baby_id)
    if after is not None:
        query = query.where(CareActivity.id > after).order_by(CareActivity.id)
    else:
        query = query.order_by(CareActivity.id.desc())
    events = (await session.execute(query.limit(100))).scalars().all()
    if after is None:
        events = list(reversed(events))
    return SuccessResponse(data={'baby_name': baby.name, 'role': await access_role(session, baby, user),
        'events': [public_event(e, user, baby.owner_user_id == user.id) for e in events]})

@router.post('/babies/{baby_id}/messages', status_code=201)
async def message(baby_id: UUID, payload: Message, user: Current, session: Session):
    baby = await accessible_baby(session, baby_id, user, write=True, lock=True)
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
