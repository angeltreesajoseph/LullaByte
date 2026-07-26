import 'package:connectivity_plus/connectivity_plus.dart';

/// Thin wrapper around `connectivity_plus`, giving the rest of the app a
/// single, testable connectivity signal (SAD Section 13.5, the `SyncEngine`
/// connectivity-change listener; Section 15.1).
///
/// This class only reports connectivity — it does not itself trigger
/// synchronization or any feature-specific behavior, both of which are
/// out of scope for the application foundation.
class NetworkChecker {
  NetworkChecker([Connectivity? connectivity]) : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;

  /// One-shot connectivity check.
  Future<bool> get isConnected async {
    final results = await _connectivity.checkConnectivity();
    return _hasConnection(results);
  }

  /// Continuous connectivity status stream, suitable for driving a Sync
  /// Status indicator (SRS Section 10.18.9) once synchronization is
  /// implemented.
  Stream<bool> get onConnectivityChanged {
    return _connectivity.onConnectivityChanged.map(_hasConnection);
  }

  bool _hasConnection(List<ConnectivityResult> results) {
    return results.any((result) => result != ConnectivityResult.none);
  }
}
