import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lullabyte/core/router/route_paths.dart';
import 'package:lullabyte/features/notifications/data/reminder_inbox.dart';
import 'package:lullabyte/features/notifications/presentation/screens/notifications_screen.dart';

Map<String, dynamic> alert(int id, {bool read = false}) => {
  'id': id,
  'activity_id': id,
  'baby_id': 'one',
  'baby_name': 'Anna',
  'actor_name': 'Caregiver',
  'kind': 'feeding',
  'summary': 'Update $id',
  'read': read,
  'created_at': DateTime.now()
      .subtract(Duration(days: id == 1 ? 1 : 0))
      .toIso8601String(),
};
void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  testWidgets('older pages stay visible during automatic refresh', (
    tester,
  ) async {
    var reads = 0;
    final api = Dio();
    api.interceptors.add(
      InterceptorsWrapper(
        onRequest: (o, h) {
          reads++;
          final more = o.queryParameters['before'] != null;
          h.resolve(
            Response(
              requestOptions: o,
              data: {
                'data': {
                  'items': [alert(more ? 1 : 2)],
                  'unread_count': 2,
                  'next_before': more ? null : 2,
                },
              },
            ),
          );
        },
      ),
    );
    await tester.pumpWidget(MaterialApp(home: NotificationsScreen(api: api)));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Load older alerts'));
    await tester.tap(find.text('Load older alerts'));
    await tester.pumpAndSettle();
    expect(find.text('Anna · Update 1'), findsOneWidget);
    await tester.pump(const Duration(seconds: 11));
    await tester.pump();
    expect(reads, 2);
    expect(find.text('Anna · Update 1'), findsOneWidget);
    expect(find.text('Reading older alerts'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets(
    'due reminders join the inbox and unread filter without fake delivery claims',
    (tester) async {
      await ReminderInbox.sync('parent', 'one', 'Anna', 'feeding', [
        {
          'id': 'r1',
          'reminder_at': DateTime.now()
              .subtract(const Duration(minutes: 1))
              .toIso8601String(),
        },
      ]);
      final api = Dio();
      api.interceptors.add(
        InterceptorsWrapper(
          onRequest: (o, h) => h.resolve(
            Response(
              requestOptions: o,
              data: {
                'data': {
                  'items': [alert(2, read: true)],
                  'unread_count': 0,
                  'next_before': null,
                  'babies': [
                    {'id': 'one', 'name': 'Anna', 'access_role': 'owner'},
                  ],
                },
              },
            ),
          ),
        ),
      );
      await tester.pumpWidget(
        MaterialApp(
          home: NotificationsScreen(api: api, reminderUid: 'parent'),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Anna · Feeding reminder due'), findsOneWidget);
      expect(find.text('1 unread'), findsOneWidget);
      await tester.tap(find.text('Unread'));
      await tester.pumpAndSettle();
      expect(find.text('Anna · Update 2'), findsNothing);
      await tester.tap(find.byTooltip('Mark all as read'));
      await tester.pumpAndSettle();
      expect(find.text('You’re all caught up'), findsOneWidget);
      expect(
        (await ReminderInbox.due('parent', {'one'})).single['read'],
        isTrue,
      );
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('phone notification target opens its authorized baby section', (
    tester,
  ) async {
    final api = Dio();
    api.interceptors.add(
      InterceptorsWrapper(
        onRequest: (o, h) {
          dynamic data;
          if (o.path == '/sharing/alerts') {
            expect(o.queryParameters['activity_id'], 42);
            data = {
              'items': [],
              'unread_count': 1,
              'next_before': null,
              'target': alert(42),
            };
          } else if (o.path == '/babies/one') {
            data = {'id': 'one', 'name': 'Anna'};
          } else {
            data = {};
          }
          h.resolve(Response(requestOptions: o, data: {'data': data}));
        },
      ),
    );
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => NotificationsScreen(api: api, initialActivity: 42),
        ),
        GoRoute(
          path: RoutePaths.feeding,
          builder: (_, _) =>
              const Scaffold(body: Text('Target feeding tracker')),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();
    expect(find.text('Target feeding tracker'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
