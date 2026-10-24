import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:lullabyte/core/router/route_paths.dart';
import 'package:lullabyte/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:lullabyte/features/baby_management/application/baby_profile_store.dart';

void main() {
  testWidgets(
    'real alerts show babies, save read state and open correct baby tracker',
    (tester) async {
      var read = false;
      final requests = <String>[];
      final api = Dio();
      api.interceptors.add(
        InterceptorsWrapper(
          onRequest: (o, h) {
            requests.add(o.path);
            dynamic data;
            if (o.path == '/sharing/alerts') {
              data = {
                'unread_count': read ? 0 : 1,
                'next_before': null,
                'items': [
                  {
                    'id': 7,
                    'baby_id': 'twin-two',
                    'baby_name': 'Ben',
                    'actor_name': 'Caregiver',
                    'kind': 'feeding',
                    'summary': 'Updated feeding records',
                    'read': read,
                    'created_at': '2026-10-22T07:00:00Z',
                  },
                ],
              };
            } else if (o.path.endsWith('/read')) {
              read = true;
              data = {};
            } else if (o.path == '/babies/twin-two') {
              data = {'id': 'twin-two', 'name': 'Ben'};
            } else {
              throw StateError(o.path);
            }
            h.resolve(Response(requestOptions: o, data: {'data': data}));
          },
        ),
      );
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (_, _) => NotificationsScreen(api: api),
          ),
          GoRoute(
            path: RoutePaths.feeding,
            builder: (_, _) =>
                Scaffold(body: Text('Feeding for ${BabyProfileStore.name}')),
          ),
        ],
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();
      expect(find.text('1 unread'), findsOneWidget);
      expect(find.textContaining('Lily'), findsNothing);
      await tester.tap(find.byTooltip('Mark all as read'));
      await tester.pumpAndSettle();
      expect(find.text('0 unread'), findsOneWidget);
      expect(requests, contains('/sharing/alerts/read'));
      await tester.tap(find.text('Ben · Updated feeding records'));
      await tester.pumpAndSettle();
      expect(find.text('Feeding for Ben'), findsOneWidget);
      expect(requests, contains('/sharing/alerts/7/read'));
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('empty inbox has no demo alerts', (tester) async {
    final api = Dio();
    api.interceptors.add(
      InterceptorsWrapper(
        onRequest: (o, h) => h.resolve(
          Response(
            requestOptions: o,
            data: {
              'data': {'unread_count': 0, 'items': [], 'next_before': null},
            },
          ),
        ),
      ),
    );
    await tester.pumpWidget(MaterialApp(home: NotificationsScreen(api: api)));
    await tester.pumpAndSettle();
    expect(find.text('No notifications yet'), findsOneWidget);
    expect(find.text('0 unread'), findsOneWidget);
    expect(find.textContaining('Priya'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
