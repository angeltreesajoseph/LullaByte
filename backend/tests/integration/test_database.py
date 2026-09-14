"""ORM/session tests using SQLite while production targets PostgreSQL."""

from datetime import date

import pytest
import pytest_asyncio
from sqlalchemy import select
from sqlalchemy.exc import IntegrityError
from sqlalchemy.ext.asyncio import async_sessionmaker, create_async_engine

from app.database.base import Base
from app.models import Baby, User


@pytest_asyncio.fixture
async def session():
    engine = create_async_engine("sqlite+aiosqlite:///:memory:")
    async with engine.begin() as connection:
        await connection.run_sync(Base.metadata.create_all)
    factory = async_sessionmaker(engine, expire_on_commit=False)
    async with factory() as database_session:
        yield database_session
    await engine.dispose()


@pytest.mark.asyncio
async def test_user_and_baby_relationship_round_trip(session) -> None:
    user = User(firebase_uid="firebase-123", email="parent@example.com", display_name="Parent")
    user.babies.append(Baby(name="Lily", birth_date=date(2026, 1, 2), gender="female"))
    session.add(user)
    await session.commit()

    result = await session.execute(select(User).where(User.email == "parent@example.com"))
    loaded_user = result.scalar_one()
    assert loaded_user.babies[0].name == "Lily"
    assert loaded_user.babies[0].owner_user_id == loaded_user.id


@pytest.mark.asyncio
async def test_unique_identity_fields_are_enforced(session) -> None:
    session.add_all(
        [
            User(firebase_uid="same", email="one@example.com"),
            User(firebase_uid="same", email="two@example.com"),
        ]
    )
    with pytest.raises(IntegrityError):
        await session.commit()
