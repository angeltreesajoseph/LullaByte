"""Account-addressed in-app invitations. No email delivery is claimed."""
from datetime import datetime, timedelta, timezone
from typing import Annotated, Literal
from uuid import UUID
from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel, Field
from sqlalchemy import select
from sqlalchemy import func
from sqlalchemy.ext.asyncio import AsyncSession
from app.auth.dependencies import get_current_user, get_verified_identity
from app.database.session import get_db_session
from app.models import Baby, BabyShare, User
from app.schemas.common import SuccessResponse
from app.core.settings import get_settings
from fastapi.responses import HTMLResponse

router = APIRouter(prefix='/api/v1/sharing', tags=['sharing'])
public_router = APIRouter()
Current = Annotated[User, Depends(get_current_user)]
Session = Annotated[AsyncSession, Depends(get_db_session)]

class Invite(BaseModel):
    email: str = Field(min_length=3, max_length=320, pattern=r'^[^\s@]+@[^\s@]+\.[^\s@]+$')
    role: Literal['viewer', 'caregiver'] = 'viewer'

class Role(BaseModel):
    role: Literal['viewer', 'caregiver']

async def owned(session, baby_id, user):
    baby = (await session.execute(select(Baby).where(
        Baby.id == baby_id, Baby.owner_user_id == user.id).with_for_update())).scalar_one_or_none()
    if baby is None:
        raise HTTPException(404, 'Owned baby profile not found.')
    return baby

def record(share, baby):
    return dict(id=str(share.id), baby_id=str(baby.id), baby_name=baby.name,
                email=share.email, role=share.role,
                status='accepted' if share.user_id else 'pending',
                expires_at=share.expires_at.isoformat(),
                invitation_url=f'{get_settings().public_api_origin.rstrip("/")}/join/{share.id}')

@public_router.get('/join/{share_id}', response_class=HTMLResponse)
async def invitation_landing(share_id: UUID):
    # Public page deliberately contains no baby, member or permission details.
    return HTMLResponse(f'''<!doctype html><html><head><meta name="viewport" content="width=device-width,initial-scale=1"><title>LullaByte invitation</title></head>
    <body style="background:#fff5f8;font-family:system-ui;padding:32px;max-width:500px;margin:auto"><h1>You're invited to share care</h1>
    <p>Open LullaByte and sign in with the email the parent invited. Verify your email before accepting.</p>
    <p><a href="lullabyte://app/join?invitation={share_id}">Open invitation in LullaByte</a></p>
    <p>If the app does not open, install LullaByte, then paste this invitation link in Profile → Family Sharing.</p>
    <p>This invitation does not grant access until the intended account accepts it.</p></body></html>''',
    headers={'Cache-Control': 'no-store', 'Referrer-Policy': 'no-referrer',
             'Content-Security-Policy': "default-src 'none'; style-src 'unsafe-inline'; base-uri 'none'; frame-ancestors 'none'"})

@router.get('')
async def overview(user: Current, session: Session,
                   identity: Annotated[object, Depends(get_verified_identity)]):
    from app.auth.firebase import VerifiedIdentity
    inbox_email = identity.email.lower() if isinstance(identity, VerifiedIdentity) and identity.email_verified and identity.email else ''
    rows = (await session.execute(select(BabyShare, Baby).join(Baby).where(
        (Baby.owner_user_id == user.id) | (BabyShare.user_id == user.id) |
        ((BabyShare.email == inbox_email) & (BabyShare.user_id.is_(None)))))).all()
    return SuccessResponse(data=[{**record(s, b), 'is_owner': b.owner_user_id == user.id} for s, b in rows])

@router.post('/babies/{baby_id}', status_code=201)
async def invite(baby_id: UUID, payload: Invite, user: Current, session: Session):
    baby = await owned(session, baby_id, user)
    email = payload.email.strip().lower()
    if email == (user.email or '').lower():
        raise HTTPException(400, 'You already own this profile.')
    previous = (await session.execute(select(BabyShare).where(
        BabyShare.baby_id == baby_id, BabyShare.email == email))).scalar_one_or_none()
    if previous:
        raise HTTPException(409, 'This person already has an invitation or access. Cancel or edit it first.')
    count = (await session.execute(select(func.count()).select_from(BabyShare).where(BabyShare.baby_id == baby_id))).scalar_one()
    if count >= 20:
        raise HTTPException(422, 'Maximum 20 invitations or members per baby. Remove an old entry first.')
    share = BabyShare(baby_id=baby_id, email=email, role=payload.role,
                      expires_at=datetime.now(timezone.utc) + timedelta(days=7))
    session.add(share)
    await session.commit()
    return SuccessResponse(data=record(share, baby))

@router.post('/{share_id:uuid}/accept')
async def accept(share_id: UUID, user: Current, session: Session,
                 identity: Annotated[object, Depends(get_verified_identity)]):
    from app.auth.firebase import VerifiedIdentity
    if not isinstance(identity, VerifiedIdentity) or not identity.email_verified or not identity.email:
        raise HTTPException(403, 'Verify your email address before accepting an invitation.')
    share = (await session.execute(select(BabyShare).where(BabyShare.id == share_id))).scalar_one_or_none()
    if share is None or share.email != identity.email.lower():
        raise HTTPException(404, 'Invitation not found.')
    # Lock in the same order as owner changes and tracker writes, then re-read.
    await session.execute(select(Baby).where(Baby.id == share.baby_id).with_for_update())
    await session.refresh(share)
    if share.user_id is not None:
        raise HTTPException(409, 'Invitation already accepted.')
    expiry = share.expires_at.replace(tzinfo=timezone.utc) if share.expires_at.tzinfo is None else share.expires_at
    if expiry <= datetime.now(timezone.utc):
        raise HTTPException(410, 'Invitation expired. Ask the parent for a new invitation.')
    existing = (await session.execute(select(BabyShare.id).where(
        BabyShare.baby_id == share.baby_id, BabyShare.user_id == user.id))).scalar_one_or_none()
    if existing is not None:
        raise HTTPException(409, 'You already have access to this baby. Decline this duplicate invitation.')
    share.user_id = user.id
    await session.commit()
    return SuccessResponse(data={'accepted': True})

@router.patch('/{share_id:uuid}')
async def permission(share_id: UUID, payload: Role, user: Current, session: Session):
    share = (await session.execute(select(BabyShare).where(BabyShare.id == share_id))).scalar_one_or_none()
    if share is None:
        raise HTTPException(404, 'Sharing entry not found.')
    await owned(session, share.baby_id, user)
    share.role = payload.role
    await session.commit()
    return SuccessResponse(data={'updated': True})

@router.delete('/{share_id:uuid}')
async def remove(share_id: UUID, user: Current, session: Session,
                 identity: Annotated[object, Depends(get_verified_identity)]):
    from app.auth.firebase import VerifiedIdentity
    share = (await session.execute(select(BabyShare).where(BabyShare.id == share_id))).scalar_one_or_none()
    if share is None:
        raise HTTPException(404, 'Sharing entry not found.')
    baby = (await session.execute(select(Baby).where(Baby.id == share.baby_id).with_for_update())).scalar_one()
    invited = isinstance(identity, VerifiedIdentity) and identity.email_verified and identity.email and share.email == identity.email.lower()
    if baby.owner_user_id != user.id and share.user_id != user.id and not invited:
        raise HTTPException(404, 'Sharing entry not found.')
    await session.delete(share)
    await session.commit()
    return SuccessResponse(data={'removed': True})
