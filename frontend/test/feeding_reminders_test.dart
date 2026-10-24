import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lullabyte/features/feeding/application/feeding_reminders.dart';
import 'package:lullabyte/features/vaccination/application/vaccination_reminders.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('dexterous.com/flutter/local_notifications');
  final calls = <MethodCall>[];
  setUp(() {
    FeedingReminders.resume('user');
    AndroidFlutterLocalNotificationsPlugin.registerWith();
    SharedPreferences.setMockInitialValues({});
    calls.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (c) async {
          calls.add(c);
          return c.method == 'requestNotificationsPermission' ? true : null;
        });
  });
  tearDown(
    () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null),
  );
  Map<String, dynamic> reminder() => {
    'id': 'test-reminder',
    'record_type': 'reminder',
    'reminder_at': DateTime.now()
        .add(const Duration(hours: 2))
        .toUtc()
        .toIso8601String(),
  };
  test(
    'separate twins schedule different notifications; cancel affects only one',
    () async {
      await FeedingReminders.sync('user', 'one', 'Anna', [reminder()]);
      await FeedingReminders.sync('user', 'two', 'Ben', [reminder()]);
      final scheduled = calls
          .where((c) => c.method == 'zonedSchedule')
          .toList();
      expect(scheduled, hasLength(2));
      expect(
        (scheduled.first.arguments as Map)['id'],
        isNot((scheduled.last.arguments as Map)['id']),
      );
      calls.clear();
      await FeedingReminders.sync('user', 'one', 'Anna', []);
      expect(calls.where((c) => c.method == 'zonedSchedule'), isEmpty);
      expect(
        (calls.single.arguments as Map)['id'],
        VaccinationReminders.id('user', 'one', 'feeding/test-reminder'),
      );
    },
  );
  test(
    'logout cancels reminders and prevents rescheduling until login',
    () async {
      await FeedingReminders.sync('user', 'one', 'Anna', [reminder()]);
      calls.clear();
      await FeedingReminders.cancelForUser('user');
      expect(calls.where((c) => c.method == 'cancel'), hasLength(1));
      calls.clear();
      await FeedingReminders.sync('user', 'one', 'Anna', [reminder()]);
      expect(calls, isEmpty);
      FeedingReminders.resume('user');
      await FeedingReminders.sync('user', 'one', 'Anna', [reminder()]);
      expect(calls.where((c) => c.method == 'zonedSchedule'), hasLength(1));
    },
  );
  test('restore both babies and skip expired reminders', () async {
    await FeedingReminders.restore('user', [
      {
        'id': 'one',
        'tracker_data': {
          'feeding': [reminder()],
        },
      },
      {
        'id': 'two',
        'tracker_data': {
          'feeding': [reminder()],
        },
      },
    ]);
    expect(calls.where((c) => c.method == 'zonedSchedule'), hasLength(2));
    calls.clear();
    await FeedingReminders.sync('user', 'one', 'Anna', [
      {
        'record_type': 'reminder',
        'reminder_at': DateTime.now()
            .subtract(const Duration(hours: 1))
            .toIso8601String(),
      },
    ]);
    expect(calls.where((c) => c.method == 'zonedSchedule'), isEmpty);
  });
  test(
    'multiple reminders retain independent ids after edit and deletion',
    () async {
      final first = reminder();
      final second = {...reminder(), 'id': 'second'};
      await FeedingReminders.sync('user', 'one', 'Anna', [first, second]);
      var scheduled = calls.where((c) => c.method == 'zonedSchedule').toList();
      expect(scheduled, hasLength(2));
      expect(
        (scheduled[0].arguments as Map)['id'],
        isNot((scheduled[1].arguments as Map)['id']),
      );
      calls.clear();
      await FeedingReminders.sync('user', 'one', 'Anna', [
        {
          ...first,
          'reminder_at': DateTime.now()
              .add(const Duration(hours: 4))
              .toUtc()
              .toIso8601String(),
        },
        second,
      ]);
      expect(calls.where((c) => c.method == 'zonedSchedule'), hasLength(2));
      calls.clear();
      await FeedingReminders.sync('user', 'one', 'Anna', [second]);
      scheduled = calls.where((c) => c.method == 'zonedSchedule').toList();
      expect(scheduled, hasLength(1));
      expect(
        (scheduled.single.arguments as Map)['id'],
        VaccinationReminders.id('user', 'one', 'feeding/second'),
      );
    },
  );
  test('legacy one-off notification is cancelled when upgrading', () async {
    SharedPreferences.setMockInitialValues({'feeding_reminder/user/one': 123});
    await FeedingReminders.sync('user', 'one', 'Anna', [reminder()]);
    expect((calls.first.arguments as Map)['id'], 123);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.containsKey('feeding_reminder/user/one'), false);
    expect(prefs.getStringList('feeding_reminders/user/one'), hasLength(1));
  });
}
