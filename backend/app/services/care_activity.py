"""All records and push recipients are calculated on the server."""
from datetime import datetime, timedelta, timezone
from sqlalchemy import select
from app.models import Baby, BabyShare
from app.models.care_activity import CareActivity, CareDelivery, CareDevice

async def add_activity(session, baby, user, kind, summary, message=None, client_id=None):
    event = CareActivity(baby_id=baby.id, actor_user_id=user.id,
        actor_name=user.display_name or 'Care team member', kind=kind,
        summary=summary, message=message, client_id=client_id)
    session.add(event)
    await session.flush()
    recipients = {baby.owner_user_id}
    # Care updates alert the parent and managers; chat alerts all accepted members.
    members = select(BabyShare.user_id).where(
        BabyShare.baby_id == baby.id, BabyShare.user_id.is_not(None))
    if kind != 'chat':
        members = members.where(BabyShare.role == 'caregiver')
    recipients.update((await session.execute(members)).scalars().all())
    recipients.discard(user.id)
    session.add_all([CareDelivery(activity_id=event.id, user_id=uid) for uid in recipients])
    return event

def public_event(event, user, owner):
    return dict(id=event.id, baby_id=str(event.baby_id), actor_name=event.actor_name,
        kind=event.kind, summary=event.summary, message=event.message,
        created_at=event.created_at.isoformat(),
        mine=event.actor_user_id == user.id,
        can_delete=event.kind == 'chat' and (event.actor_user_id == user.id or owner))

def send_push(tokens, baby_id, activity_id):
    from firebase_admin import messaging
    # No baby name, cry reason or chat text is exposed on the lock screen.
    return messaging.send_each_for_multicast(messaging.MulticastMessage(
        tokens=tokens, notification=messaging.Notification(title='LullaByte',
            body='New shared care activity. Open the app to view it.'),
        data={'baby_id': str(baby_id), 'activity_id': str(activity_id)},
        android=messaging.AndroidConfig(priority='high',
            notification=messaging.AndroidNotification(channel_id='shared_care', tag=str(activity_id)))))

async def deliver_pending(session):
    import asyncio
    now = datetime.now(timezone.utc)
    rows = (await session.execute(select(CareDelivery).where(
        CareDelivery.sent.is_(False), CareDelivery.attempts < 5,
        (CareDelivery.last_attempt.is_(None)) | (CareDelivery.last_attempt < now - timedelta(minutes=1))
    ).order_by(CareDelivery.id).limit(50).with_for_update(skip_locked=True))).scalars().all()
    for delivery in rows:
        event = await session.get(CareActivity, delivery.activity_id)
        baby = await session.get(Baby, event.baby_id)
        grant = (await session.execute(select(BabyShare.role).where(
            BabyShare.baby_id == event.baby_id, BabyShare.user_id == delivery.user_id))).scalar_one_or_none()
        if baby is None or (baby.owner_user_id != delivery.user_id and grant is None):
            delivery.sent = True  # cancelled after revocation
            continue
        if baby.owner_user_id != delivery.user_id and event.kind != 'chat' and grant != 'caregiver':
            delivery.sent = True  # permission was downgraded while queued
            continue
        tokens = (await session.execute(select(CareDevice.token).where(CareDevice.user_id == delivery.user_id,
            CareDevice.registered_at <= event.created_at))).scalars().all()
        if not tokens:
            # Don't replay a backlog when notifications are enabled later.
            delivery.sent = True
            continue
        delivery.last_attempt = now
        delivery.attempts += 1
        try:
            response = await asyncio.to_thread(send_push, tokens[:500], event.baby_id, event.id)
            delivery.sent = response.failure_count == 0
            for token, result in zip(tokens, response.responses):
                if not result.success and type(result.exception).__name__ in {'UnregisteredError', 'SenderIdMismatchError'}:
                    device = await session.get(CareDevice, token)
                    if device:
                        await session.delete(device)
        except Exception:
            import logging
            logging.getLogger('lullabyte.push').warning('Shared care push failed; queued for retry (no record data logged).')
    await session.commit()

async def push_worker(settings):
    import asyncio
    from app.auth.firebase import FirebaseTokenVerifier
    from app.database.session import create_session_factory
    factory = create_session_factory(settings)
    try:
        while True:
            try:
                # Reuse the same Firebase project credentials as authentication.
                await asyncio.to_thread(FirebaseTokenVerifier(settings)._initialize)
                async with factory() as session:
                    await deliver_pending(session)
            except Exception:
                import logging
                logging.getLogger('lullabyte.push').warning('Shared care push worker unavailable; will retry.')
            await asyncio.sleep(15)
    finally:
        await factory.kw['bind'].dispose()
