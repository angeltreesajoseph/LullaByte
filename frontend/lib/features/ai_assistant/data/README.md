# AI Parenting Assistant — Data Layer

Concrete data access for AI Parenting Assistant (SAD Section 7.5, Repository Pattern
Section 6.2): local-first reads/writes against SQLite, with synchronization
to the FastAPI backend handled transparently, per the Offline-First strategy
(SAD Section 2.4, Section 6.6, Section 13).
