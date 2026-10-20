import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lullabyte/features/vaccination/application/vaccination_reminders.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('dexterous.com/flutter/local_notifications');
  final calls = <MethodCall>[];
  setUp(() {
    VaccinationReminders.resumeForUser('user');
    AndroidFlutterLocalNotificationsPlugin.registerWith();
    calls.clear();
    SharedPreferences.setMockInitialValues({});
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          calls.add(call);
          return call.method == 'requestNotificationsPermission' ? true : null;
        });
  });
  tearDown(
    () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null),
  );
  Map<String, dynamic> entry(String id) => {
    'id': id,
    'name': 'MR dose 1',
    'done': false,
    'excluded': false,
    'reminder_at': DateTime.now()
        .add(const Duration(days: 2))
        .toUtc()
        .toIso8601String(),
  };
  test(
    'schedule uses inexact local notification and cancels on completion',
    () async {
      final record = entry('mr_1');
      await VaccinationReminders.sync('user', 'one', 'Twin one', [record]);
      expect(calls.where((c) => c.method == 'zonedSchedule'), hasLength(1));
      calls.clear();
      await VaccinationReminders.sync('user', 'one', 'Twin one', [
        {...record, 'done': true},
      ]);
      expect(calls.where((c) => c.method == 'cancel'), hasLength(1));
      expect(calls.where((c) => c.method == 'zonedSchedule'), isEmpty);
    },
  );
  test('deleting one twin reminder does not cancel the other twin', () async {
    await VaccinationReminders.sync('user', 'one', 'Twin one', [entry('mr_1')]);
    await VaccinationReminders.sync('user', 'two', 'Twin two', [entry('mr_1')]);
    calls.clear();
    await VaccinationReminders.sync('user', 'one', 'Twin one', []);
    final cancelled = calls.where((c) => c.method == 'cancel').toList();
    expect(cancelled, hasLength(1));
    expect(
      (cancelled.single.arguments as Map)['id'],
      VaccinationReminders.id('user', 'one', 'mr_1'),
    );
  });
  test('past and excluded reminders are not scheduled', () async {
    await VaccinationReminders.sync('user', 'one', 'Baby', [
      {
        ...entry('past'),
        'reminder_at': DateTime.now()
            .subtract(const Duration(days: 1))
            .toIso8601String(),
      },
      {...entry('excluded'), 'excluded': true},
    ]);
    expect(calls.where((c) => c.method == 'zonedSchedule'), isEmpty);
  });
  test('home restores saved reminders for both twins', () async {
    await VaccinationReminders.restore('user', [
      {
        'id': 'one',
        'name': 'Twin one',
        'tracker_data': {
          'vaccinations': [entry('mr_1')],
        },
      },
      {
        'id': 'two',
        'name': 'Twin two',
        'tracker_data': {
          'vaccinations': [entry('mr_1')],
        },
      },
    ]);
    final scheduled = calls.where((c) => c.method == 'zonedSchedule').toList();
    expect(scheduled, hasLength(2));
    expect(
      (scheduled[0].arguments as Map)['id'],
      isNot((scheduled[1].arguments as Map)['id']),
    );
  });
  test(
    'logout cancels this user and blocks in-flight rescheduling until login',
    () async {
      await VaccinationReminders.sync('user', 'one', 'Baby', [entry('mr_1')]);
      calls.clear();
      await VaccinationReminders.cancelForUser('user');
      expect(calls.where((c) => c.method == 'cancel'), hasLength(1));
      calls.clear();
      await VaccinationReminders.sync('user', 'one', 'Baby', [entry('mr_1')]);
      expect(calls, isEmpty);
      VaccinationReminders.resumeForUser('user');
      await VaccinationReminders.sync('user', 'one', 'Baby', [entry('mr_1')]);
      expect(calls.where((c) => c.method == 'zonedSchedule'), hasLength(1));
    },
  );
}
