"""Account avatar kept out of the identity row and baby profile payloads."""
from uuid import UUID
from sqlalchemy import ForeignKey, Text, Uuid
from sqlalchemy.orm import Mapped, mapped_column
from app.database.base import Base


class AccountPhoto(Base):
    __tablename__ = 'account_photos'
    user_id: Mapped[UUID] = mapped_column(
        Uuid, ForeignKey('users.id', ondelete='CASCADE'), primary_key=True)
    photo_data: Mapped[str] = mapped_column(Text, nullable=False)
