import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Chosen reminder times, not proof that the OS delivered a notification.
/// Local to this phone/account; shared-care alerts are stored on the server.
class ReminderInbox {
  static Future<List<Map<String, dynamic>>> _read(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('reminder_inbox/$uid');
    if (raw == null) return [];
    try {
      return (jsonDecode(raw) as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> _write(
    String uid,
    List<Map<String, dynamic>> rows,
  ) async {
    await (await SharedPreferences.getInstance()).setString(
      'reminder_inbox/$uid',
      jsonEncode(rows),
    );
  }

  static Future<void> _queue = Future.value();
  static Future<void> _serial(Future<void> Function() action) {
    final next = _queue.then((_) => action());
    _queue = next.catchError((Object _) {});
    return next;
  }

  static Future<void> sync(
    String uid,
    String baby,
    String name,
    String kind,
    List<Map<String, dynamic>> reminders,
  ) => _serial(() async {
    final now = DateTime.now();
    final entries = await _read(uid);
    // Cancelled/edited future reminders disappear; already-due history remains.
    entries.removeWhere(
      (e) =>
          e['baby_id'] == baby &&
          e['kind'] == kind &&
          (DateTime.tryParse(e['created_at'] as String)?.isAfter(now) ?? false),
    );
    for (final r in reminders) {
      final at = DateTime.tryParse(r['reminder_at']?.toString() ?? '');
      if (at == null || r['done'] == true || r['excluded'] == true) continue;
      final id =
          'reminder/$kind/$baby/${r['id'] ?? ''}/${at.toUtc().toIso8601String()}';
      if (entries.any((e) => e['id'] == id)) continue;
      entries.add({
        'id': id,
        'source': 'reminder',
        'baby_id': baby,
        'baby_name': name,
        'kind': kind,
        'summary': kind == 'feeding'
            ? 'Feeding reminder due'
            : '${r['name'] ?? 'Vaccination'} reminder due',
        'actor_name': 'Your chosen reminder',
        'created_at': at.toUtc().toIso8601String(),
        'read': false,
      });
    }
    entries.sort(
      (a, b) =>
          (b['created_at'] as String).compareTo(a['created_at'] as String),
    );
    await _write(uid, entries.take(500).toList());
  });
  static Future<List<Map<String, dynamic>>> due(
    String uid,
    Set<String> accessible, {
    DateTime? now,
  }) async {
    final rows = await _read(uid), clock = now ?? DateTime.now();
    return rows
        .where(
          (e) =>
              accessible.contains(e['baby_id']) &&
              !(DateTime.tryParse(e['created_at'] as String)?.isAfter(clock) ??
                  true),
        )
        .toList();
  }

  static Future<void> markRead(String uid, Iterable<String> ids) =>
      _serial(() async {
        final selected = ids.toSet(), rows = await _read(uid);
        for (final row in rows) {
          if (selected.contains(row['id'])) row['read'] = true;
        }
        await _write(uid, rows);
      });
}
