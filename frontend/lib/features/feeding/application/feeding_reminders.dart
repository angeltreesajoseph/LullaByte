import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:convert';
import 'dart:typed_data';
import '../../notifications/data/reminder_inbox.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;
import '../../vaccination/application/vaccination_reminders.dart';

/// Multiple caregiver-selected one-off reminders, never a feeding prescription.
class FeedingReminders {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static final _paused = <String>{};
  static Future<void> _pending = Future.value();
  static void resume(String uid) => _paused.remove(uid);
  static Future<void> _queue(Future<void> Function() action) {
    final next = _pending.then((_) => action());
    _pending = next.catchError((Object _) {});
    return next;
  }

  static Future<bool> permission() => VaccinationReminders.requestPermission();
  static Future<void> sync(
    String uid,
    String baby,
    String name,
    List<Map<String, dynamic>> rows,
  ) => _queue(() async {
    if (_paused.contains(uid)) return;
    await ReminderInbox.sync(
      uid,
      baby,
      name,
      'feeding',
      rows.where((r) => r['record_type'] == 'reminder').toList(),
    );
    tzdata.initializeTimeZones();
    final prefs = await SharedPreferences.getInstance();
    final key = 'feeding_reminders/$uid/$baby';
    final legacyKey = 'feeding_reminder/$uid/$baby';
    final legacyId = prefs.getInt(legacyKey);
    if (legacyId != null) await _plugin.cancel(id: legacyId);
    await prefs.remove(legacyKey);
    for (final value in prefs.getStringList(key) ?? <String>[]) {
      await _plugin.cancel(id: int.parse(value));
    }
    await prefs.setStringList(key, []);
    final scheduled = <String>[];
    final reminders = rows.where((r) => r['record_type'] == 'reminder');
    for (final reminder in reminders) {
      final at = DateTime.tryParse(reminder['reminder_at'] as String? ?? '');
      if (at == null || !at.isAfter(DateTime.now())) continue;
      final id = VaccinationReminders.id(
        uid,
        baby,
        'feeding/${reminder['id'] ?? reminder['reminder_at']}',
      );
      await _plugin.zonedSchedule(
        id: id,
        title: 'Feeding reminder',
        body: '$name: your chosen feeding reminder.',
        scheduledDate: tz.TZDateTime.from(at, tz.getLocation('Asia/Kolkata')),
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            'feeding',
            'Feeding reminders',
            importance: Importance.high,
            enableVibration: true,
            vibrationPattern: Int64List.fromList([0, 400, 200, 400]),
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        payload: jsonEncode({
          'type': 'reminder',
          'uid': uid,
          'baby_id': baby,
          'id':
              'reminder/feeding/$baby/${reminder['id'] ?? ''}/${at.toUtc().toIso8601String()}',
        }),
      );
      scheduled.add('$id');
      await prefs.setStringList(key, scheduled);
    }
  });

  static Future<void> restore(
    String uid,
    List<Map<String, dynamic>> babies,
  ) async {
    for (final baby in babies) {
      await sync(
        uid,
        baby['id'] as String,
        baby['name'] as String? ?? 'Baby',
        (baby['access_role'] == 'viewer'
                ? <dynamic>[]
                : ((baby['tracker_data'] as Map?)?['feeding'] as List? ?? []))
            .map((r) => Map<String, dynamic>.from(r as Map))
            .toList(),
      );
    }
  }

  static Future<void> cancelForUser(String uid) {
    _paused.add(uid);
    return _queue(() async {
      final prefs = await SharedPreferences.getInstance();
      for (final key in prefs.getKeys().where(
        (k) =>
            k.startsWith('feeding_reminder/$uid/') ||
            k.startsWith('feeding_reminders/$uid/'),
      )) {
        if (key.startsWith('feeding_reminders/')) {
          for (final value in prefs.getStringList(key) ?? <String>[]) {
            await _plugin.cancel(id: int.parse(value));
          }
        } else {
          final id = prefs.getInt(key);
          if (id != null) await _plugin.cancel(id: id);
        }
        await prefs.remove(key);
      }
    });
  }
}
