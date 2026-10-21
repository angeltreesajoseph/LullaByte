from uuid import UUID
from fastapi import HTTPException
from sqlalchemy import select
from app.models import Baby, BabyShare

async def accessible_baby(session, baby_id: UUID, user, *, write=False, lock=False):
    # Serialize grants/revocations and writes on the same baby row.
    query = select(Baby).where(Baby.id == baby_id).execution_options(populate_existing=True)
    if lock:
        query = query.with_for_update()
    baby = (await session.execute(query)).scalar_one_or_none()
    if baby is None:
        raise HTTPException(404, 'Baby profile not found.')
    if baby.owner_user_id != user.id:
        grant = (await session.execute(select(BabyShare).where(
            BabyShare.baby_id == baby_id, BabyShare.user_id == user.id))).scalar_one_or_none()
        if grant is None:
            raise HTTPException(404, 'Baby profile not found.')
        if write and grant.role != 'caregiver':
            raise HTTPException(403, 'View-only access cannot change care records.')
    return baby

async def access_role(session, baby, user):
    if baby.owner_user_id == user.id:
        return 'owner'
    return (await session.execute(select(BabyShare.role).where(
        BabyShare.baby_id == baby.id, BabyShare.user_id == user.id))).scalar_one()
