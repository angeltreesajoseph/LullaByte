"""Per-baby invitations and accepted grants."""
from datetime import datetime
from uuid import UUID, uuid4
from sqlalchemy import DateTime, ForeignKey, String, UniqueConstraint, Uuid
from sqlalchemy.orm import Mapped, mapped_column
from app.database.base import Base


class BabyShare(Base):
    __tablename__ = 'baby_shares'
    __table_args__ = (UniqueConstraint('baby_id', 'email', name='uq_baby_share_email'),
                      UniqueConstraint('baby_id', 'user_id', name='uq_baby_share_user'))
    id: Mapped[UUID] = mapped_column(Uuid, primary_key=True, default=uuid4)
    baby_id: Mapped[UUID] = mapped_column(Uuid, ForeignKey('babies.id', ondelete='CASCADE'), index=True)
    email: Mapped[str] = mapped_column(String(320), index=True)
    role: Mapped[str] = mapped_column(String(20))
    user_id: Mapped[UUID | None] = mapped_column(Uuid, ForeignKey('users.id', ondelete='CASCADE'), index=True)
    expires_at: Mapped[datetime] = mapped_column(DateTime(timezone=True))
