import 'package:logger/logger.dart';

/// Thin wrapper around the `logger` package providing a single, consistent
/// logging entry point for the whole application (SAD Section 11.4.4 /
/// NFR-MAINT-07–08).
///
/// Feature modules should depend on [AppLogger] via [appLoggerProvider]
/// (see `core/di/providers.dart`) rather than constructing their own
/// `Logger` instance, so log formatting and filtering stay consistent
/// app-wide.
class AppLogger {
  AppLogger({Logger? logger})
      : _logger = logger ??
            Logger(
              printer: PrettyPrinter(
                methodCount: 1,
                errorMethodCount: 8,
                lineLength: 100,
                colors: true,
                printEmojis: true,
              ),
            );

  final Logger _logger;

  void debug(String message, [Object? error, StackTrace? stackTrace]) =>
      _logger.d(message, error: error, stackTrace: stackTrace);

  void info(String message, [Object? error, StackTrace? stackTrace]) =>
      _logger.i(message, error: error, stackTrace: stackTrace);

  void warning(String message, [Object? error, StackTrace? stackTrace]) =>
      _logger.w(message, error: error, stackTrace: stackTrace);

  void error(String message, [Object? error, StackTrace? stackTrace]) =>
      _logger.e(message, error: error, stackTrace: stackTrace);
}
