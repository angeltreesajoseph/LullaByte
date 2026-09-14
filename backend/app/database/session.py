"""Async SQLAlchemy engine and FastAPI session dependency."""

from collections.abc import AsyncIterator

from fastapi import HTTPException
from sqlalchemy.ext.asyncio import (
    AsyncEngine,
    AsyncSession,
    async_sessionmaker,
    create_async_engine,
)

from app.core.settings import Settings, get_settings


def create_engine(settings: Settings) -> AsyncEngine:
    """Create an engine explicitly; importing the app never opens a database."""

    if not settings.database_url:
        raise RuntimeError(
            "LULLABYTE_DATABASE_URL is required before database access is used."
        )
    return create_async_engine(
        settings.database_url,
        echo=settings.database_echo,
        pool_pre_ping=True,
    )


def create_session_factory(settings: Settings) -> async_sessionmaker[AsyncSession]:
    return async_sessionmaker(
        create_engine(settings), expire_on_commit=False, class_=AsyncSession
    )


async def get_db_session() -> AsyncIterator[AsyncSession]:
    """Yield one request-scoped session and roll back failed requests."""

    settings = get_settings()
    try:
        factory = create_session_factory(settings)
    except RuntimeError as error:
        raise HTTPException(status_code=503, detail="Database is not configured.") from error

    async with factory() as session:
        try:
            yield session
        except Exception:
            await session.rollback()
            raise
        finally:
            await session.close()

