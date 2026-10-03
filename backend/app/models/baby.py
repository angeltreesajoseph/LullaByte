"""Baby profile owned by a user."""

from datetime import date
from decimal import Decimal
from uuid import UUID, uuid4

from sqlalchemy import Date, ForeignKey, JSON, Numeric, String, Text, Uuid
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.database.base import Base, TimestampMixin


class Baby(TimestampMixin, Base):
    __tablename__ = "babies"

    id: Mapped[UUID] = mapped_column(Uuid, primary_key=True, default=uuid4)
    owner_user_id: Mapped[UUID] = mapped_column(
        Uuid, ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True
    )
    name: Mapped[str] = mapped_column(String(120), nullable=False)
    photo_data: Mapped[str | None] = mapped_column(Text)
    tracker_data: Mapped[dict | None] = mapped_column(JSON)
    birth_date: Mapped[date | None] = mapped_column(Date)
    gender: Mapped[str | None] = mapped_column(String(32))
    birth_weight_kg: Mapped[Decimal | None] = mapped_column(Numeric(5, 2))
    birth_length_cm: Mapped[Decimal | None] = mapped_column(Numeric(5, 2))
    blood_group: Mapped[str | None] = mapped_column(String(16))
    allergies: Mapped[str | None] = mapped_column(String(500))
    pediatrician: Mapped[str | None] = mapped_column(String(160))
    hospital: Mapped[str | None] = mapped_column(String(160))
    head_circumference_cm: Mapped[Decimal | None] = mapped_column(Numeric(5, 2))

    owner: Mapped["User"] = relationship(back_populates="babies")
