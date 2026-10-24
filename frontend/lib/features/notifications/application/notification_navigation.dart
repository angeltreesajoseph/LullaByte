import 'dart:convert';
import 'package:flutter/foundation.dart';

/// Only identifiers are carried by notification taps; access is checked on open.
class NotificationNavigation {
  static final pending = ValueNotifier<Map<String, String>?>(null);
  static void shared(Map<String, dynamic> data) {
    final id = int.tryParse(data['activity_id']?.toString() ?? '');
    if (id == null || id < 1) return;
    pending.value = {'activity': id.toString()};
  }

  static void local(String? payload) {
    try {
      final data = Map<String, dynamic>.from(jsonDecode(payload ?? '') as Map);
      if (data['type'] == 'shared') {
        shared(data);
        return;
      }
      if (data['type'] == 'reminder' &&
          data['uid'] is String &&
          data['baby_id'] is String) {
        pending.value = {
          'reminder': data['id'].toString(),
          'uid': data['uid'] as String,
        };
      }
    } catch (_) {
      /* Ignore old or malformed payloads. */
    }
  }
}
