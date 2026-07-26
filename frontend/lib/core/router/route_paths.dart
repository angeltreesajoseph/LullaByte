/// Route path and name constants for every screen registered with
/// [GoRouter] (SAD Section 7.2; SRS Section 10.5.6, Navigation).
///
/// Centralizing these avoids typo-prone string literals scattered across
/// feature modules — every `context.go(...)` / `GoRoute(path: ...)` call
/// should reference [RoutePaths], never a hardcoded string.
class RoutePaths {
  const RoutePaths._();

  static const String splash = '/';
  static const String onboarding = '/onboarding';

  // Authentication (SRS Section 10.1)
  static const String login = '/login';
  static const String register = '/register';

  // Dashboard (SRS Section 10.5)
  static const String dashboard = '/dashboard';

  // Baby Management (SRS Section 10.3, 10.4, 10.13)
  static const String babyRegistration = '/baby/register';
  static const String babyProfile = '/baby/profile';

  // Feature modules (SRS Section 10.6–10.21)
  static const String cryAnalyzer = '/cry-analyzer';
  static const String feeding = '/feeding';
  static const String sleep = '/sleep';
  static const String diaper = '/diaper';
  static const String vaccination = '/vaccination';
  static const String growth = '/growth';
  static const String milestones = '/milestones';
  static const String gallery = '/gallery';
  static const String reports = '/reports';
  static const String aiAssistant = '/ai-assistant';
  static const String settings = '/settings';
  static const String search = '/search';
  static const String familySharing = '/family-sharing';
  static const String notifications = '/notifications';
}

/// Route `name` values, used with `context.goNamed(...)` as a refactor-safe
/// alternative to path strings. Kept 1:1 with [RoutePaths].
class RouteNames {
  const RouteNames._();

  static const String splash = 'splash';
  static const String onboarding = 'onboarding';
  static const String login = 'login';
  static const String register = 'register';
  static const String dashboard = 'dashboard';
  static const String babyRegistration = 'babyRegistration';
  static const String babyProfile = 'babyProfile';
  static const String cryAnalyzer = 'cryAnalyzer';
  static const String feeding = 'feeding';
  static const String sleep = 'sleep';
  static const String diaper = 'diaper';
  static const String vaccination = 'vaccination';
  static const String growth = 'growth';
  static const String milestones = 'milestones';
  static const String gallery = 'gallery';
  static const String reports = 'reports';
  static const String aiAssistant = 'aiAssistant';
  static const String settings = 'settings';
  static const String search = 'search';
  static const String familySharing = 'familySharing';
  static const String notifications = 'notifications';
}
