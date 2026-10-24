import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lullabyte/core/router/main_navigation_shell.dart';
import 'package:lullabyte/core/router/route_paths.dart';
import 'package:lullabyte/features/baby_management/application/baby_profile_store.dart';
import 'package:lullabyte/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:lullabyte/features/family_sharing/presentation/screens/chat_inbox_screen.dart';

void main() {
  setUp(() => GoogleFonts.config.allowRuntimeFetching = false);
  testWidgets('dashboard circle opens the selected twin profile', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(430, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final babies = [
      {'id': 'one', 'name': 'Anna'},
      {'id': 'two', 'name': 'Ben'},
    ];
    BabyProfileStore.select(babies[1]);
    final api = Dio();
    api.interceptors.add(
      InterceptorsWrapper(
        onRequest: (o, h) {
          h.resolve(Response(requestOptions: o, data: {'data': babies}));
        },
      ),
    );
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => DashboardScreen(api: api),
        ),
        GoRoute(
          path: RoutePaths.babyProfile,
          builder: (_, _) =>
              Scaffold(body: Text('Profile for ${BabyProfileStore.name}')),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    expect(find.text('Join a baby’s care team'), findsNothing);
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    expect(find.text('Join a baby’s care team'), findsNothing);
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('dashboard_profile_button')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Profile for Ben'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('bottom bar opens Messages', (tester) async {
    final router = GoRouter(
      initialLocation: RoutePaths.dashboard,
      routes: [
        StatefulShellRoute.indexedStack(
          builder: (_, _, shell) => MainNavigationShell(navigationShell: shell),
          branches: [
            for (final path in [
              RoutePaths.dashboard,
              RoutePaths.trackers,
              RoutePaths.gallery,
              RoutePaths.chat,
            ])
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: path,
                    builder: (_, _) => const Scaffold(body: Text('Content')),
                  ),
                ],
              ),
          ],
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();
    expect(find.text('Profile'), findsNothing);
    await tester.tap(find.text('Messages'));
    await tester.pumpAndSettle();
    expect(router.routeInformationProvider.value.uri.path, RoutePaths.chat);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('one baby opens messages directly without a profile tap', (tester) async {
    final api = Dio();
    String? opened;
    api.interceptors.add(InterceptorsWrapper(onRequest: (o, h) {
      if (o.path == '/sharing/conversations') {
        h.resolve(Response(requestOptions: o, data: {
          'data': [{'baby_id': 'one', 'baby_name': 'Anna', 'members': 2}],
        }));
      } else {
        opened = o.path;
        expect(o.queryParameters['chat_only'], true);
        h.resolve(Response(requestOptions: o, data: {
          'data': {'baby_name': 'Anna', 'role': 'viewer', 'can_chat': true, 'events': []},
        }));
      }
    }));
    await tester.pumpWidget(MaterialApp(home: ChatInboxScreen(api: api)));
    await tester.pumpAndSettle();
    expect(opened, '/sharing/babies/one/activity');
    expect(find.byKey(const ValueKey('care_chat_composer')), findsOneWidget);
    expect(find.byKey(const ValueKey('chat_one')), findsNothing);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets(
    'chat inbox keeps baby conversations separate and opens the right one',
    (tester) async {
      final api = Dio();
      String? opened;
      api.interceptors.add(
        InterceptorsWrapper(
          onRequest: (o, h) {
            if (o.path == '/sharing/conversations') {
              h.resolve(
                Response(
                  requestOptions: o,
                  data: {
                    'data': [
                      {
                        'baby_id': 'one',
                        'baby_name': 'Anna',
                        'members': 2,
                        'last_message': 'Anna feed recorded',
                        'last_sender': 'Parent',
                      },
                      {
                        'baby_id': 'two',
                        'baby_name': 'Ben',
                        'members': 2,
                        'last_message': 'Ben nap started',
                        'last_sender': 'Caregiver',
                      },
                    ],
                  },
                ),
              );
            } else {
              opened = o.path;
              expect(o.queryParameters['chat_only'], true);
              h.resolve(
                Response(
                  requestOptions: o,
                  data: {
                    'data': {
                      'baby_name': 'Ben',
                      'role': 'viewer',
                      'can_chat': true,
                      'events': [],
                    },
                  },
                ),
              );
            }
          },
        ),
      );
      await tester.pumpWidget(MaterialApp(home: ChatInboxScreen(api: api)));
      await tester.pumpAndSettle();
      expect(find.text('Anna'), findsOneWidget);
      expect(find.text('Ben'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('chat_two')));
      await tester.pumpAndSettle();
      expect(opened, '/sharing/babies/two/activity');
      expect(find.text('Care team chat'), findsOneWidget);
      expect(find.byKey(const ValueKey('care_chat_composer')), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    },
  );
}
