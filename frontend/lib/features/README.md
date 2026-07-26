# features

One self-contained Feature Module per functional module defined in SRS
Section 10 and described architecturally in SAD Section 8 (Module-wise
Architecture). Each feature is internally structured per Clean Architecture
(SAD Section 6.1) into four sub-layers:

| Sub-layer | Role |
|---|---|
| `presentation/` | Screens and widgets (the View in MVVM, SAD Section 7.2) |
| `application/` | Riverpod ViewModels/controllers (the ViewModel in MVVM, SAD Section 7.3) |
| `domain/` | Entities, use cases, and repository interfaces (SAD Section 7.4) |
| `data/` | Repository implementations, local (SQLite) and remote (Dio/FastAPI) data sources, and data models (Repository Pattern, SAD Section 6.2, Section 7.5) |

## Feature Modules

| Folder | SRS Section | SAD Section |
|---|---|---|
| `authentication/` | 10.1 | 8.2 |
| `dashboard/` | 10.5 | 8.3 |
| `baby_management/` | 10.3, 10.4 | 8.4 |
| `cry_analyzer/` | 10.6 | 8.5 |
| `feeding/` | 10.7 | 8.6 |
| `sleep/` | 10.8 | 8.7 |
| `diaper/` | 10.9 | 8.8 |
| `vaccination/` | 10.10 | 8.9 |
| `growth/` | 10.14 | 8.10 |
| `baby_management/` (profile extensions) | 10.13 | 8.11 |
| `milestones/` | 10.11 | 8.12 |
| `gallery/` | 10.12 | 8.13 |
| `notifications/` | 10.17 | 8.14 |
| `reports/` | 10.16 | 8.15 |
| `ai_assistant/` | 10.15 | 8.16 |
| `settings/` | 10.21 | 8.17 |
| `family_sharing/` | 10.20 | 8.18 |
| `search/` | 10.19 | 8.19 |
