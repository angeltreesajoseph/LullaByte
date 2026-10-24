import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lullabyte/features/notifications/data/reminder_inbox.dart';
import 'package:lullabyte/features/notifications/application/notification_navigation.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    NotificationNavigation.pending.value = null;
  });
  test(
    'due reminders are deduplicated, account-isolated and access-filtered',
    () async {
      final now = DateTime.now(),
          past = DateTime.now().subtract(const Duration(hours: 1)),
          future = DateTime.now().add(const Duration(days: 1));
      final rows = [
        {'id': 'a', 'reminder_at': past.toIso8601String()},
        {'id': 'b', 'reminder_at': future.toIso8601String()},
      ];
      await ReminderInbox.sync('parent', 'one', 'Anna', 'feeding', rows);
      await ReminderInbox.sync('parent', 'one', 'Anna', 'feeding', rows);
      final due = await ReminderInbox.due('parent', {'one'}, now: now);
      expect(due, hasLength(1));
      expect(await ReminderInbox.due('other', {'one'}), isEmpty);
      expect(await ReminderInbox.due('parent', {'two'}), isEmpty);
      await ReminderInbox.markRead('parent', [due.single['id'] as String]);
      expect(
        (await ReminderInbox.due('parent', {'one'})).single['read'],
        isTrue,
      );
      await ReminderInbox.sync('parent', 'one', 'Anna', 'feeding', []);
      expect(
        await ReminderInbox.due('parent', {
          'one',
        }, now: future.add(const Duration(days: 2))),
        hasLength(1),
      );
    },
  );
  test(
    'notification taps keep identifiers only and ignore malformed payloads',
    () {
      NotificationNavigation.local('broken');
      expect(NotificationNavigation.pending.value, isNull);
      NotificationNavigation.shared({'activity_id': 'bad'});
      expect(NotificationNavigation.pending.value, isNull);
      NotificationNavigation.shared({
        'activity_id': '42',
        'baby_id': 'one',
        'private_text': 'never store',
      });
      expect(NotificationNavigation.pending.value, {'activity': '42'});
      NotificationNavigation.local(
        jsonEncode({
          'type': 'reminder',
          'uid': 'parent',
          'baby_id': 'one',
          'id': 'reminder/feeding/one/abc',
        }),
      );
      expect(NotificationNavigation.pending.value, {
        'reminder': 'reminder/feeding/one/abc',
        'uid': 'parent',
      });
    },
  );
}
