import 'package:flutter/foundation.dart';

/// Signals a read-state change without caching another account's alerts.
class SharedAlertInbox extends ChangeNotifier {
  static final changes = SharedAlertInbox();
  static void updated() => changes.notifyListeners();
}
