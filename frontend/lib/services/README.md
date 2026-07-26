# services

App-wide services consumed via Dependency Injection (SAD Section 6.5) by
multiple feature modules:

- **SyncEngine** — Offline Synchronization orchestration (SRS Section 10.18, SAD Section 13.2)
- **NotificationDispatcher** — unified Local/Push notification dispatch (SRS Section 10.17, SAD Section 8.14)
- **SecureStorageService** — encrypted local storage for JWTs and the SQLite encryption key (SAD Section 12.5)
- **LocalDatabaseService** — SQLite database lifecycle management (SAD Section 9)
- **FirebaseService** — Firebase Authentication and Cloud Messaging SDK wrapper
- **CloudinaryService** — media upload coordination for the Gallery feature
