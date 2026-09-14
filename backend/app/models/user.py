"""Identity record owned by the backend."""

from uuid import UUID, uuid4

from sqlalchemy import Boolean, String, Uuid
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.database.base import Base, TimestampMixin


class User(TimestampMixin, Base):
    __tablename__ = "users"

    id: Mapped[UUID] = mapped_column(Uuid, primary_key=True, default=uuid4)
    firebase_uid: Mapped[str | None] = mapped_column(String(128), unique=True)
    email: Mapped[str | None] = mapped_column(String(320), unique=True)
    display_name: Mapped[str | None] = mapped_column(String(160))
    is_active: Mapped[bool] = mapped_column(Boolean, default=True, nullable=False)

    babies: Mapped[list["Baby"]] = relationship(
        back_populates="owner", cascade="all, delete-orphan"
    )

