import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/ai_assistant/presentation/screens/ai_assistant_screen.dart';
import '../../features/authentication/presentation/screens/login_screen.dart';
import '../../features/authentication/presentation/screens/register_screen.dart';
import '../../features/baby_management/presentation/screens/baby_profile_screen.dart';
import '../../features/baby_management/presentation/screens/baby_registration_screen.dart';
import '../../features/cry_analyzer/presentation/screens/cry_analyzer_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/diaper/presentation/screens/diaper_screen.dart';
import '../../features/family_sharing/presentation/screens/family_sharing_screen.dart';
import '../../features/feeding/presentation/screens/feeding_screen.dart';
import '../../features/gallery/presentation/screens/gallery_screen.dart';
import '../../features/growth/presentation/screens/growth_screen.dart';
import '../../features/milestones/presentation/screens/milestones_screen.dart';
import '../../features/notifications/presentation/screens/notifications_screen.dart';
import '../../features/reports/presentation/screens/reports_screen.dart';
import '../../features/search/presentation/screens/search_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/sleep/presentation/screens/sleep_screen.dart';
import '../../features/vaccination/presentation/screens/vaccination_screen.dart';
import '../../screens/onboarding_screen.dart';
import '../../screens/splash_screen.dart';
import 'route_paths.dart';

/// Application routing configuration (SAD Section 7.2; SRS Section 10.5.6,
/// Navigation), built with `go_router`.
///
/// Every route currently resolves to a [PlaceholderScreen]-backed screen
/// (see `lib/widgets/placeholder_screen.dart`). No authentication-gated
/// redirect logic is applied yet — that belongs to the Authentication
/// feature (SAD Section 8.2) and is intentionally out of scope for the
/// application foundation.
final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: RoutePaths.splash,
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: RoutePaths.splash,
        name: RouteNames.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: RoutePaths.onboarding,
        name: RouteNames.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: RoutePaths.login,
        name: RouteNames.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: RoutePaths.register,
        name: RouteNames.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: RoutePaths.dashboard,
        name: RouteNames.dashboard,
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: RoutePaths.babyRegistration,
        name: RouteNames.babyRegistration,
        builder: (context, state) => const BabyRegistrationScreen(),
      ),
      GoRoute(
        path: RoutePaths.babyProfile,
        name: RouteNames.babyProfile,
        builder: (context, state) => const BabyProfileScreen(),
      ),
      GoRoute(
        path: RoutePaths.cryAnalyzer,
        name: RouteNames.cryAnalyzer,
        builder: (context, state) => const CryAnalyzerScreen(),
      ),
      GoRoute(
        path: RoutePaths.feeding,
        name: RouteNames.feeding,
        builder: (context, state) => const FeedingScreen(),
      ),
      GoRoute(
        path: RoutePaths.sleep,
        name: RouteNames.sleep,
        builder: (context, state) => const SleepScreen(),
      ),
      GoRoute(
        path: RoutePaths.diaper,
        name: RouteNames.diaper,
        builder: (context, state) => const DiaperScreen(),
      ),
      GoRoute(
        path: RoutePaths.vaccination,
        name: RouteNames.vaccination,
        builder: (context, state) => const VaccinationScreen(),
      ),
      GoRoute(
        path: RoutePaths.growth,
        name: RouteNames.growth,
        builder: (context, state) => const GrowthScreen(),
      ),
      GoRoute(
        path: RoutePaths.milestones,
        name: RouteNames.milestones,
        builder: (context, state) => const MilestonesScreen(),
      ),
      GoRoute(
        path: RoutePaths.gallery,
        name: RouteNames.gallery,
        builder: (context, state) => const GalleryScreen(),
      ),
      GoRoute(
        path: RoutePaths.reports,
        name: RouteNames.reports,
        builder: (context, state) => const ReportsScreen(),
      ),
      GoRoute(
        path: RoutePaths.aiAssistant,
        name: RouteNames.aiAssistant,
        builder: (context, state) => const AiAssistantScreen(),
      ),
      GoRoute(
        path: RoutePaths.settings,
        name: RouteNames.settings,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: RoutePaths.search,
        name: RouteNames.search,
        builder: (context, state) => const SearchScreen(),
      ),
      GoRoute(
        path: RoutePaths.familySharing,
        name: RouteNames.familySharing,
        builder: (context, state) => const FamilySharingScreen(),
      ),
      GoRoute(
        path: RoutePaths.notifications,
        name: RouteNames.notifications,
        builder: (context, state) => const NotificationsScreen(),
      ),
    ],
  );
});
