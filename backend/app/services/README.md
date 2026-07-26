# services

Business logic and orchestration, one service per module (SAD Section 8),
e.g., `AuthService`, `FeedingService`, `VaccinationService`,
`CryAnalyzerService`. Coordinates between `repositories/`, `storage/`,
`notifications/`, and the AI Prediction Service (`ai/`) — this is where the
System Behaviour rules from SRS Section 10 are implemented server-side.
