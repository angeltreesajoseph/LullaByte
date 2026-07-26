import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../logger/app_logger.dart';

/// Installs process-wide error handling for uncaught Flutter framework
/// errors and uncaught async (platform dispatcher) errors, per SAD Section
/// 14.1: no unhandled exception should silently crash the app or vanish
/// from the logs.
///
/// This does not implement any feature-specific error handling (SRS
/// Section 10 Error Handling subsections) — it is the app-wide safety net
/// beneath all of it.
class ErrorHandler {
  ErrorHandler(this._logger);

  final AppLogger _logger;

  void install() {
    final previousOnError = FlutterError.onError;
    FlutterError.onError = (FlutterErrorDetails details) {
      _logger.error(
        'Uncaught Flutter framework error',
        details.exception,
        details.stack,
      );
      previousOnError?.call(details);
    };

    PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
      _logger.error('Uncaught async error', error, stack);
      return true;
    };
  }

  /// Builds the fallback UI shown if a widget throws during build, in place
  /// of Flutter's default red error screen — kept intentionally minimal and
  /// non-technical, consistent with the plain-language accessibility
  /// principle of SRS Section 15.
  static Widget buildErrorWidget(FlutterErrorDetails details) {
    return Material(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
              SizedBox(height: 12),
              Text(
                'Something went wrong.',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
