import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

class VaccinationReminders {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _ready = false;
  static final Set<String> _pausedUsers = {};
  static Future<void> _pending = Future.value();
  static void resumeForUser(String user) => _pausedUsers.remove(user);
  static Future<void> _queue(Future<void> Function() action) {
    final operation = _pending.then((_) => action());
    _pending = operation.catchError((Object _) {});
    return operation;
  }

  static int id(String user, String baby, String dose) {
    var hash = 2166136261;
    for (final c in '$user/$baby/$dose'.codeUnits) {
      hash = ((hash ^ c) * 16777619) & 0x7fffffff;
    }
    return hash;
  }

  static Future<bool> requestPermission() async {
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android != null)
      return await android.requestNotificationsPermission() ?? false;
    final ios = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    return await ios?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        ) ??
        false;
  }

  static Future<void> sync(
    String user,
    String baby,
    String name,
    List<Map<String, dynamic>> entries,
  ) => _queue(() async {
    if (!_pausedUsers.contains(user)) await _sync(user, baby, name, entries);
  });

  static Future<void> restore(String user, List<Map<String, dynamic>> babies) =>
      _queue(() async {
        if (_pausedUsers.contains(user)) return;
        for (final baby in babies) {
          if (_pausedUsers.contains(user)) return;
          final rows =
              ((baby['tracker_data'] as Map?)?['vaccinations'] as List? ?? [])
                  .map((e) => Map<String, dynamic>.from(e as Map))
                  .toList();
          await _sync(
            user,
            baby['id'] as String,
            baby['name'] as String? ?? 'Baby',
            rows,
          );
        }
      });

  static Future<void> _sync(
    String user,
    String baby,
    String name,
    List<Map<String, dynamic>> entries,
  ) async {
    if (!_ready) {
      tzdata.initializeTimeZones();
      _ready = true;
    }
    final prefs = await SharedPreferences.getInstance();
    final key = 'vaccination_reminders/$user/$baby';
    final old = prefs.getStringList(key) ?? [];
    final current = <String>[];
    // Keep only this feature's ids; do not cancel other notification types.
    for (final value in old) {
      await _plugin.cancel(id: int.parse(value));
    }
    await prefs.setStringList(key, []);
    for (final entry in entries) {
      final date = DateTime.tryParse(entry['reminder_at'] as String? ?? '');
      if (date == null ||
          !date.isAfter(DateTime.now()) ||
          entry['done'] == true ||
          entry['excluded'] == true)
        continue;
      final notificationId = id(user, baby, entry['id'] as String);
      await _plugin.zonedSchedule(
        id: notificationId,
        scheduledDate: tz.TZDateTime.from(date, tz.getLocation('Asia/Kolkata')),
        title: 'Vaccination reminder',
        body:
            '$name: ${entry['name']}. Confirm timing with your paediatrician.',
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'vaccinations',
            'Vaccination reminders',
            channelDescription: 'Reminders you choose for your baby',
            importance: Importance.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
      current.add('$notificationId');
      await prefs.setStringList(key, current);
    }
  }

  static Future<void> cancelForUser(String user) {
    _pausedUsers.add(user);
    return _queue(() => _cancelForUser(user));
  }

  static Future<void> _cancelForUser(String user) async {
    final prefs = await SharedPreferences.getInstance();
    for (final key in prefs.getKeys().where(
      (key) => key.startsWith('vaccination_reminders/$user/'),
    )) {
      for (final value in prefs.getStringList(key) ?? <String>[]) {
        await _plugin.cancel(id: int.parse(value));
      }
      await prefs.remove(key);
    }
  }
}
