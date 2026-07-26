/// Build-time / environment configuration for LullaByte.
///
/// Values here are placeholders for the application foundation (SAD Section
/// 16.3, Environment Tiers). Real per-environment values (dev/staging/prod
/// API base URLs, Firebase project selection) will be supplied via
/// `--dart-define` build flavors when the backend integration milestone
/// begins — no live endpoint is called from the foundation itself.
class AppConfig {
  const AppConfig._();

  static const String appName = 'LullaByte';

  static const AppEnvironment environment = AppEnvironment.development;

  /// Base URL of the FastAPI backend (SAD Section 10). Not yet reachable —
  /// no network calls are made by the application foundation.
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.lullabyte.example.com/api/v1',
  );

  static const Duration apiConnectTimeout = Duration(seconds: 15);
  static const Duration apiReceiveTimeout = Duration(seconds: 20);
}

enum AppEnvironment { development, staging, production }
