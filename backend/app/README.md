# app

Root Python package for the backend application.

| Folder | Role |
|---|---|
| `routers/` | FastAPI route definitions — the HTTP boundary (SAD Section 10) |
| `models/` | SQLAlchemy ORM models mapping to the PostgreSQL schema (SAD Section 9.3) |
| `schemas/` | Pydantic request/response schemas (SAD Section 10.4) |
| `services/` | Business logic and orchestration per module (SAD Section 8) |
| `repositories/` | Repository Pattern data-access implementations (SAD Section 6.2) |
| `database/` | Database session management and migrations |
| `core/` | App configuration, settings, and dependency-injection wiring |
| `middleware/` | Global HTTP middleware (CORS, logging, exception handling) |
| `auth/` | Authentication/authorization infrastructure (JWT, RoleGuard, Firebase verification) |
| `storage/` | Cloudinary media storage integration |
| `notifications/` | Firebase Cloud Messaging dispatch service |
| `utils/` | Generic backend helper functions |
