import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/di/providers.dart';
import 'core/error/error_handler.dart';
import 'core/logger/app_logger.dart';
import 'core/router/app_router.dart';
import 'core/router/route_paths.dart';
import 'core/theme/app_theme.dart';
import 'features/family_sharing/application/shared_care_notifications.dart';
import 'features/notifications/application/notification_navigation.dart';
import 'screens/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final bootstrapLogger = AppLogger();
  final errorHandler = ErrorHandler(bootstrapLogger);
  errorHandler.install();
  ErrorWidget.builder = ErrorHandler.buildErrorWidget;

  // Draw the complete brand screen before plugin initialization, not after it.
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: AppTheme.light,
    themeMode: ThemeMode.light,
    home: const BrandedLoadingScreen(),
  ));
  await WidgetsBinding.instance.endOfFrame;

  // A missing platform configuration must not prevent app startup.
  try {
    await Firebase.initializeApp();
    bootstrapLogger.info('Firebase initialized.');
  } catch (error, stackTrace) {
    bootstrapLogger.warning(
      'Firebase initialization skipped (no project configured yet).',
      error,
      stackTrace,
    );
  }

  // Register tap handling before reminders or foreground alerts are shown.
  try {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    );
    final localNotifications = FlutterLocalNotificationsPlugin();
    await localNotifications.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (response) =>
          NotificationNavigation.local(response.payload),
    );
    final launch = await localNotifications.getNotificationAppLaunchDetails();
    if (launch?.didNotificationLaunchApp == true)
      NotificationNavigation.local(launch?.notificationResponse?.payload);
    bootstrapLogger.info('Local notifications plugin initialized.');
  } catch (error, stackTrace) {
    bootstrapLogger.warning(
      'Local notifications initialization failed.',
      error,
      stackTrace,
    );
  }

  final sharedPreferences = await SharedPreferences.getInstance();
  try {
    await SharedCareNotifications.start();
  } catch (error, stack) {
    bootstrapLogger.warning(
      'Shared care notifications unavailable; enable them from Family Sharing to retry.',
      error,
      stack,
    );
  }

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: const LullaByteApp(),
    ),
  );
}

/// Application root. Keep the pastel interface in light mode, including
/// dialogs and form fields, regardless of device or legacy theme preferences.
class LullaByteApp extends ConsumerWidget {
  const LullaByteApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);

    return MaterialApp.router(
      title: 'LullaByte',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      themeMode: ThemeMode.light,
      routerConfig: RouterConfig(
        routeInformationProvider: router.routeInformationProvider,
        routeInformationParser: router.routeInformationParser,
        routerDelegate: router.routerDelegate,
        backButtonDispatcher: _AppBackDispatcher(router),
      ),
    );
  }
}

class _AppBackDispatcher extends RootBackButtonDispatcher {
  _AppBackDispatcher(this.router);

  final GoRouter router;

  @override
  Future<bool> didPopRoute() async {
    // First allow normal pops, dialogs and unsaved-form guards to handle Back.
    if (await super.didPopRoute()) return true;
    final path = router.routeInformationProvider.value.uri.path;
    if ({
      RoutePaths.splash,
      RoutePaths.onboarding,
      RoutePaths.login,
      RoutePaths.register,
      RoutePaths.babyRegistration,
      RoutePaths.dashboard,
    }.contains(path)) return false;
    router.go(RoutePaths.dashboard);
    return true;
  }
}
