# backend

The FastAPI backend service for LullaByte (SAD Section 7.6): a stateless REST
API mediating all access to PostgreSQL, Firebase, Cloudinary, and the AI
Prediction Service.

Follows a layered architecture: `routers/` (HTTP boundary) → `services/`
(business logic/orchestration) → `repositories/` (Repository Pattern data
access) → `database/` (PostgreSQL connection/session management), with
`core/`, `middleware/`, `auth/`, `storage/`, `notifications/`, and `utils/`
providing cross-cutting infrastructure consumed across all modules.

The project manifest (`pyproject.toml`/`requirements.txt`) and application
entry point are intentionally not created yet — this is folder structure
only.
