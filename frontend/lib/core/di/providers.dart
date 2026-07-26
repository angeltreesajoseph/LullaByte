import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../logger/app_logger.dart';
import '../network/dio_client.dart';
import '../network/network_checker.dart';

/// Central Dependency Injection wiring (SAD Section 6.5): the single place
/// where concrete implementations of cross-cutting services are bound to
/// Riverpod providers, ready to be consumed by any feature module via
/// `ref.watch` / `ref.read`.
///
/// Feature-specific providers (repositories, ViewModels) are declared
/// inside each feature's own `application`/`data` layers and are not
/// defined here.

/// Overridden in `main.dart` with the resolved [SharedPreferences] instance
/// once `SharedPreferences.getInstance()` completes, following the standard
/// Riverpod pattern for wrapping required async bootstrap dependencies.
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
    'sharedPreferencesProvider must be overridden in main.dart before runApp().',
  );
});

final appLoggerProvider = Provider<AppLogger>((ref) => AppLogger());

final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

final networkCheckerProvider = Provider<NetworkChecker>((ref) => NetworkChecker());

/// Continuous connectivity signal, suitable for a future Sync Status
/// indicator (SRS Section 10.18.9). Not consumed anywhere in the
/// application foundation yet.
final connectivityStatusProvider = StreamProvider<bool>((ref) {
  return ref.watch(networkCheckerProvider).onConnectivityChanged;
});

final dioClientProvider = Provider<Dio>((ref) {
  final logger = ref.watch(appLoggerProvider);
  return DioClientFactory(logger).create();
});
