# LullaByte — AI Powered Newborn Care Assistant

Monorepo for the LullaByte project: a Flutter mobile client, a FastAPI backend,
and an AI cry-analysis/parenting-assistant module, backed by PostgreSQL (cloud),
SQLite (offline), Firebase (Authentication + Cloud Messaging), and Cloudinary
(media storage).

This structure implements the design defined in:

- `docs/LullaByte_SRS.md` — Software Requirements Specification (v1.1, Final)
- `docs/architecture/LullaByte_Software_Architecture.md` — Software Architecture Document (SAD)

These two documents are authoritative and are **not** modified by this scaffold.

## Top-Level Layout

| Folder | Purpose |
|---|---|
| `frontend/` | Flutter mobile client (Clean Architecture, Feature-first, MVVM via Riverpod) |
| `backend/` | FastAPI backend service (REST API, PostgreSQL access, orchestration) |
| `ai/` | AI Cry Analyzer and AI Parenting Assistant training/inference pipeline |
| `docs/` | SRS, SAD, and generated PDF — authoritative, not modified by this scaffold |
| `Dataset/` | Raw labeled infant-cry audio dataset (source data for `ai/training`) |
| `scripts/` | Setup, database, and deployment automation scripts |
| `docker/` | Container definitions for the backend, AI service, and reverse proxy |
| `tests/` | Cross-cutting integration, end-to-end, and performance tests |

Component-specific and layer-specific README files are provided throughout the
tree; each explains the purpose of that folder and references the relevant
SRS/SAD section. No Dart, Python, SQL, or configuration files have been created
yet — this commit is folder structure and documentation only.
