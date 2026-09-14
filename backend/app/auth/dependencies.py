"""FastAPI dependencies for Firebase identity and database users."""

from typing import Annotated

from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.auth.firebase import AuthenticationError, FirebaseTokenVerifier
from app.core.settings import Settings, get_settings
from app.database.session import get_db_session
from app.models import User

bearer_scheme = HTTPBearer(auto_error=False)


def get_token_verifier(settings: Annotated[Settings, Depends(get_settings)]) -> FirebaseTokenVerifier:
    return FirebaseTokenVerifier(settings)


async def get_verified_identity(
    credentials: Annotated[HTTPAuthorizationCredentials | None, Depends(bearer_scheme)],
    verifier: Annotated[FirebaseTokenVerifier, Depends(get_token_verifier)],
) -> object:
    if credentials is None or credentials.scheme.lower() != "bearer":
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Authentication is required.",
            headers={"WWW-Authenticate": "Bearer"},
        )
    try:
        return verifier.verify(credentials.credentials)
    except AuthenticationError as error:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail=str(error),
            headers={"WWW-Authenticate": "Bearer"},
        ) from error


async def get_current_user(
    identity: Annotated[object, Depends(get_verified_identity)],
    session: Annotated[AsyncSession, Depends(get_db_session)],
) -> User:
    # The identity dependency deliberately runs before database acquisition so
    # missing/invalid credentials return 401 even when the database is offline.
    from app.auth.firebase import VerifiedIdentity

    if not isinstance(identity, VerifiedIdentity):  # defensive boundary check
        raise HTTPException(status_code=401, detail="Authentication is required.")

    result = await session.execute(
        select(User).where(User.firebase_uid == identity.firebase_uid)
    )
    user = result.scalar_one_or_none()
    if user is None:
        user = User(
            firebase_uid=identity.firebase_uid,
            email=identity.email,
            display_name=identity.display_name,
        )
        session.add(user)
    else:
        user.email = identity.email or user.email
        user.display_name = identity.display_name or user.display_name
    await session.commit()
    await session.refresh(user)
    if not user.is_active:
        raise HTTPException(status_code=403, detail="This account is inactive.")
    return user
