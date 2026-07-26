# routers

FastAPI `APIRouter` modules — the HTTP boundary layer (SAD Section 7.6,
Section 10.2). One router module per functional area, each depending on the
shared JWT/RoleGuard dependency defined in `app/auth/` before any handler
logic executes.

Planned router modules (SAD Section 10.2 endpoint grouping): `auth.py`,
`babies.py`, `cry_predictions.py`, `feeding.py`, `sleep.py`, `diaper.py`,
`vaccinations.py`, `growth.py`, `milestones.py`, `media.py` (Gallery),
`notifications.py`, `reports.py`, `ai_assistant.py`, `account.py` (Settings),
`sharing.py` (Family Sharing), `search.py`, `sync.py`.
