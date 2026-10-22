"""Authenticated online assistant; baby records are never forwarded to Google."""
from collections import deque
from time import monotonic
from typing import Annotated, Literal
from uuid import UUID
from fastapi import APIRouter, Depends, HTTPException, Request
from pydantic import BaseModel, Field
from sqlalchemy.ext.asyncio import AsyncSession
from app.auth.dependencies import get_current_user
from app.database.session import get_db_session
from app.models import User
from app.schemas.common import SuccessResponse
from app.services.baby_access import accessible_baby
from app.services.gemini_assistant import generate

router = APIRouter(prefix='/api/v1/babies', tags=['assistant'])


class Turn(BaseModel):
    role: Literal['user', 'model']
    text: str = Field(min_length=1, max_length=12000)


class Question(BaseModel):
    question: str = Field(min_length=1, max_length=1000)
    history: list[Turn] = Field(default_factory=list, max_length=8)
    consent: bool = False


@router.post('/{baby_id}/assistant', response_model=SuccessResponse)
async def ask(baby_id: UUID, payload: Question, request: Request,
              user: Annotated[User, Depends(get_current_user)],
              session: Annotated[AsyncSession, Depends(get_db_session)]):
    await accessible_baby(session, baby_id, user)
    if not payload.consent:
        raise HTTPException(400, 'Consent is required before sending questions to Gemini.')
    if not payload.question.strip():
        raise HTTPException(422, 'Enter a question.')
    # Best-effort per-process guard; also set provider-side project quotas.
    now = monotonic()
    limits = getattr(request.app.state, 'assistant_limits', None)
    if limits is None:
        limits = request.app.state.assistant_limits = {}
    if len(limits) > 10000:
        for key in list(limits):
            if not limits[key] or limits[key][-1] < now - 60:
                del limits[key]
    queue = limits.setdefault(str(user.id), deque())
    while queue and queue[0] < now - 60:
        queue.popleft()
    if len(queue) >= 10:
        raise HTTPException(429, 'Please wait a minute before sending more questions.')
    queue.append(now)
    # Release the read transaction/connection before a slow provider request.
    # Authorization has already been checked; this endpoint never writes care data.
    await session.rollback()
    answer = await generate(request.app.state.settings, payload.question.strip(), payload.history)
    return SuccessResponse(data={'answer': answer, 'provider': 'gemini'})
