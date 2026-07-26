import 'package:dio/dio.dart';

import '../config/app_config.dart';
import '../logger/app_logger.dart';

/// Builds the shared Dio HTTP client used by every feature's remote data
/// source (SAD Section 7.5, Section 10.1 REST API Design Principles).
///
/// This is transport configuration only: base URL, timeouts, and request/
/// response logging. It intentionally does not attach a JWT interceptor or
/// retry/backoff policy yet — those belong to the Authentication (SAD
/// Section 8.2) and Offline Synchronization (SAD Section 13) features,
/// which are out of scope for the application foundation.
class DioClientFactory {
  const DioClientFactory(this._logger);

  final AppLogger _logger;

  Dio create() {
    final dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout: AppConfig.apiConnectTimeout,
        receiveTimeout: AppConfig.apiReceiveTimeout,
        headers: const {'Content-Type': 'application/json'},
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          _logger.debug('→ ${options.method} ${options.uri}');
          handler.next(options);
        },
        onResponse: (response, handler) {
          _logger.debug('← ${response.statusCode} ${response.requestOptions.uri}');
          handler.next(response);
        },
        onError: (error, handler) {
          _logger.warning(
            '✗ ${error.requestOptions.method} ${error.requestOptions.uri} — ${error.message}',
          );
          handler.next(error);
        },
      ),
    );

    return dio;
  }
}
