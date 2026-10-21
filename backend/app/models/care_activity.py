"""Shared-care audit stream, chat and private push delivery queue."""
from datetime import datetime
from uuid import UUID
from sqlalchemy import Boolean, DateTime, ForeignKey, Integer, String, Text, UniqueConstraint, Uuid
from sqlalchemy.orm import Mapped, mapped_column
from app.database.base import Base, utc_now

class CareActivity(Base):
    __tablename__ = 'care_activity'
    __table_args__ = (UniqueConstraint('baby_id', 'actor_user_id', 'client_id', name='uq_care_message_retry'),)
    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    baby_id: Mapped[UUID] = mapped_column(Uuid, ForeignKey('babies.id', ondelete='CASCADE'), index=True)
    actor_user_id: Mapped[UUID] = mapped_column(Uuid, ForeignKey('users.id', ondelete='CASCADE'))
    actor_name: Mapped[str] = mapped_column(String(160))
    kind: Mapped[str] = mapped_column(String(32))
    summary: Mapped[str] = mapped_column(String(240))
    message: Mapped[str | None] = mapped_column(Text)
    client_id: Mapped[str | None] = mapped_column(String(64))
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=utc_now, index=True)

class CareDevice(Base):
    __tablename__ = 'care_devices'
    token: Mapped[str] = mapped_column(String(4096), primary_key=True)
    user_id: Mapped[UUID] = mapped_column(Uuid, ForeignKey('users.id', ondelete='CASCADE'), index=True)
    registered_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=utc_now)

class CareDelivery(Base):
    __tablename__ = 'care_deliveries'
    __table_args__ = (UniqueConstraint('activity_id', 'user_id', name='uq_care_delivery'),)
    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    activity_id: Mapped[int] = mapped_column(Integer, ForeignKey('care_activity.id', ondelete='CASCADE'), index=True)
    user_id: Mapped[UUID] = mapped_column(Uuid, ForeignKey('users.id', ondelete='CASCADE'))
    sent: Mapped[bool] = mapped_column(Boolean, default=False)
    attempts: Mapped[int] = mapped_column(Integer, default=0)
    last_attempt: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))
