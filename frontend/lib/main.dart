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
import 'core/theme/app_theme.dart';
import 'core/theme/theme_mode_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final bootstrapLogger = AppLogger();
  final errorHandler = ErrorHandler(bootstrapLogger);
  errorHandler.install();
  ErrorWidget.builder = ErrorHandler.buildErrorWidget;

  // Firebase Authentication and Cloud Messaging (SAD Section 7.9, 12.2) are
  // not yet configured for this platform (no google-services.json /
  // firebase_options.dart — see SAD Section 16.2, follow-up step). The
  // initialization call is wired here so the app boots cleanly once a
  // Firebase project is attached, but a missing/failed configuration must
  // never prevent the rest of the app foundation from running.
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

  // Local notification plugin bootstrap only (SAD Section 7.9, 12.11).
  // No notification channels or scheduled notifications are registered
  // yet — that is Notification System feature work (SRS Section 10.17).
  try {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);
    await FlutterLocalNotificationsPlugin().initialize(settings: initSettings);
    bootstrapLogger.info('Local notifications plugin initialized.');
  } catch (error, stackTrace) {
    bootstrapLogger.warning('Local notifications initialization failed.', error, stackTrace);
  }

  final sharedPreferences = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: const LullaByteApp(),
    ),
  );
}

/// Application root widget: wires Riverpod-provided [GoRouter] and
/// [ThemeMode] into a [MaterialApp.router] using the Light/Dark themes
/// defined in `core/theme/app_theme.dart` (SAD Section 6.3, 6.5).
class LullaByteApp extends ConsumerWidget {
  const LullaByteApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'LullaByte',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
