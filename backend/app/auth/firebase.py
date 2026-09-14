"""Firebase ID-token verification with lazy SDK initialization."""

from dataclasses import dataclass
from typing import Any

from app.core.settings import Settings


class AuthenticationError(Exception):
    """Raised when a bearer token is absent, invalid, or unverifiable."""


@dataclass(frozen=True)
class VerifiedIdentity:
    firebase_uid: str
    email: str | None
    display_name: str | None


class FirebaseTokenVerifier:
    """Verify Firebase tokens without initializing Firebase at import time."""

    def __init__(self, settings: Settings) -> None:
        self._settings = settings
        self._initialized = False

    def _initialize(self) -> None:
        if self._initialized:
            return
        try:
            import firebase_admin
            from firebase_admin import credentials
        except ImportError as error:  # pragma: no cover - dependency is packaged
            raise AuthenticationError("Firebase authentication is unavailable.") from error

        if firebase_admin._apps:
            self._initialized = True
            return
        try:
            if self._settings.firebase_service_account_json:
                credential = credentials.Certificate(
                    self._settings.firebase_service_account_json
                )
                firebase_admin.initialize_app(
                    credential, {"projectId": self._settings.firebase_project_id}
                )
            else:
                firebase_admin.initialize_app(
                    options={"projectId": self._settings.firebase_project_id}
                )
        except Exception as error:
            raise AuthenticationError(
                "Firebase authentication is not configured correctly."
            ) from error
        self._initialized = True

    def verify(self, token: str) -> VerifiedIdentity:
        self._initialize()
        try:
            from firebase_admin import auth

            claims: dict[str, Any] = auth.verify_id_token(token)
        except Exception as error:
            raise AuthenticationError("The authentication token is invalid.") from error

        uid = str(claims.get("uid") or claims.get("sub") or "").strip()
        if not uid:
            raise AuthenticationError("The authentication token has no user identity.")
        return VerifiedIdentity(
            firebase_uid=uid,
            email=claims.get("email"),
            display_name=claims.get("name") or claims.get("display_name"),
        )

