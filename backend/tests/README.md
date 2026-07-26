# tests

Backend automated tests (pytest convention).

| Folder | Scope |
|---|---|
| `unit/` | Isolated tests for `services/`, `repositories/`, and `utils/`, with `database/` and external integrations mocked |
| `integration/` | Tests exercising `routers/` against a real (test) PostgreSQL instance, verifying end-to-end request handling per SRS Section 10 |
