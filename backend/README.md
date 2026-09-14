# backend

The FastAPI backend service for LullaByte: a stateless REST API that will
mediate access to PostgreSQL, Firebase, Cloudinary, and the AI prediction
service.

The intended layered architecture is `routers/` (HTTP boundary) to
`services/` (business logic) to `repositories/` (data access) to `database/`
(PostgreSQL sessions). Cross-cutting infrastructure belongs in `core/`,
`middleware/`, `auth/`, `storage/`, `notifications/`, and `utils/`.

## Current implementation

The first executable service foundation is available:

- environment-validated settings under `app/core/`;
- a FastAPI application factory and ASGI entry point in `app/main.py`;
- CORS, request correlation, access logging, and standard error envelopes;
- an operational `GET /health` endpoint;
- versioned OpenAPI at `/api/v1/openapi.json` and local docs at `/docs`;
- isolated unit and API-boundary tests.

Feature-domain routers beyond account/babies, storage, notifications, and AI
inference remain intentionally unimplemented. Firebase token verification is
implemented for protected routes but requires project credentials.

The initial database slice is now present: async SQLAlchemy session
infrastructure, Alembic migration `0001_initial_identity`, and `User`/`Baby`
ORM models. Production database access requires `LULLABYTE_DATABASE_URL`.

Protected identity/profile routes are available at `/api/v1/account/me` and
`/api/v1/babies`. They require `Authorization: Bearer <Firebase ID token>` and
scope every baby query to the authenticated owner.

## Local development

From the repository root on Windows PowerShell:

```powershell
python -m venv backend/.venv
backend/.venv/Scripts/python.exe -m pip install -e "backend[dev]"
Set-Location backend
.venv/Scripts/python.exe -m uvicorn app.main:app --reload
```

The service will be available at `http://127.0.0.1:8000`; its health endpoint
is `http://127.0.0.1:8000/health`.

Run the backend tests from `backend/`:

```powershell
.venv/Scripts/python.exe -m pytest -p no:cacheprovider
```

Copy `.env.example` to `.env` only when local overrides are needed. Never
commit `.env` or credentials.
