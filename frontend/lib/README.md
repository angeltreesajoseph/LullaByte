# lib

Root Dart source package for the Flutter application.

| Folder | Role |
|---|---|
| `core/` | Cross-cutting foundational code shared by every feature (DI, error types, network client, base use cases) |
| `config/` | Environment/app configuration and build flavors |
| `theme/` | Global Material 3 theme, including Light/Dark/High-Contrast modes (SRS Section 10.21.2, Section 15.10) |
| `utils/` | App-wide utility/helper functions |
| `widgets/` | Global reusable UI widgets shared across features |
| `screens/` | Top-level/shell screens not owned by a single feature (e.g., splash, root navigation shell) |
| `models/` | Global/shared data models used across multiple features |
| `providers/` | App-wide Riverpod providers (active baby profile, auth state, connectivity, theme) |
| `repositories/` | Shared repository contracts/base abstractions used across features |
| `services/` | App-wide services: SyncEngine, NotificationDispatcher, SecureStorageService, ApiClient (Dio), local database access |
| `shared/` | Cross-feature building blocks (mixins, extensions, shared validators) that don't fit elsewhere |
| `features/` | One self-contained module per SRS Section 10 functional module (SAD Section 6.4, Section 8) |
