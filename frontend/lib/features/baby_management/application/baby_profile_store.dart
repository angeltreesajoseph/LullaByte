/// Session cache for the active baby name shared by presentation screens.
import 'package:flutter/foundation.dart';

class BabyProfileStore {
  BabyProfileStore._();
  static String name = 'Your baby';
  static String? id;
  static Map<String, dynamic> data = const {};
  static List<Map<String, dynamic>> babies = const [];
  static final changes = ValueNotifier<int>(0);

  /// Only reuse a complete server snapshot for the currently selected baby.
  /// Logout clears this session store; callers still refresh before saving.
  static Map<String, dynamic>? snapshotFor(String? babyId) {
    if (babyId == null ||
        id != babyId ||
        data['id'] != babyId ||
        data['tracker_data'] is! Map ||
        data['tracker_revisions'] is! Map)
      return null;
    return Map<String, dynamic>.from(data);
  }

  static void rememberSnapshot(Map<String, dynamic> baby) {
    if (baby['id'] != id) return;
    data = Map<String, dynamic>.from(baby);
    babies = babies.map((entry) => entry['id'] == id ? data : entry).toList();
  }

  static void select(Map<String, dynamic> baby) {
    id = baby['id'] as String?;
    name = (baby['name'] as String?)?.trim().isNotEmpty == true
        ? (baby['name'] as String).trim()
        : 'Your baby';
    data = Map<String, dynamic>.from(baby);
    changes.value++;
  }
}
