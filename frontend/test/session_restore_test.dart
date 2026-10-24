import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:lullabyte/screens/splash_screen.dart';
import 'package:lullabyte/core/router/route_paths.dart';
import 'package:lullabyte/features/family_sharing/application/shared_care_connection.dart';

Future<void> boot(WidgetTester tester, Stream<bool> Function() session) async {
  final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (_, __) => SplashScreen(sessionChanges: session, minimumDisplay: Duration.zero),
      ),
      GoRoute(
        path: RoutePaths.login,
        builder: (_, __) => const Scaffold(body: Text('Login destination')),
      ),
      GoRoute(
        path: RoutePaths.dashboard,
        builder: (_, __) => const Scaffold(body: Text('Dashboard destination')),
      ),
      GoRoute(
        path: RoutePaths.familySharing,
        builder: (_, __) =>
            const Scaffold(body: Text('Invitation destination')),
      ),
    ],
  );
  addTearDown(router.dispose);
  await tester.pumpWidget(MaterialApp.router(routerConfig: router));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
}

void main() {
  testWidgets('fast restored session still shows full name and description', (tester) async {
    final router = GoRouter(routes: [
      GoRoute(path: '/', builder: (_, _) => SplashScreen(sessionChanges: () => Stream.value(true))),
      GoRoute(path: RoutePaths.dashboard, builder: (_, _) => const Text('Ready')),
    ]);
    addTearDown(router.dispose);
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('LullaByte'), findsOneWidget);
    expect(find.text('Track your baby’s care. Stay connected, wherever you are.'), findsOneWidget);
    expect(find.text('Ready'), findsNothing);
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(find.text('Ready'), findsOneWidget);
  });
  tearDown(() => PendingCareInvitation.id = null);
  testWidgets('restored sign-in opens dashboard without showing login', (
    tester,
  ) async {
    await boot(tester, () => Stream.value(true));
    expect(find.text('Dashboard destination'), findsOneWidget);
    expect(find.text('Login destination'), findsNothing);
  });
  testWidgets('signed-out session opens login', (tester) async {
    await boot(tester, () => Stream.value(false));
    expect(find.text('Login destination'), findsOneWidget);
  });
  testWidgets(
    'startup waits for auth restoration rather than assuming signed out',
    (tester) async {
      final session = StreamController<bool>();
      addTearDown(session.close);
      await boot(tester, () => session.stream);
      expect(find.text('LullaByte'), findsOneWidget);
      expect(find.text('Track your baby’s care. Stay connected, wherever you are.'), findsOneWidget);
      expect(find.bySemanticsLabel('Baby cradled by a crescent moon'), findsOneWidget);
      await tester.pump(const Duration(seconds: 3));
      expect(find.text('Login destination'), findsNothing);
      session.add(true);
      await tester.pumpAndSettle();
      expect(find.text('Dashboard destination'), findsOneWidget);
    },
  );
  testWidgets('restored login retains pending invitation flow', (tester) async {
    PendingCareInvitation.id = 'pending';
    await boot(tester, () => Stream.value(true));
    expect(find.text('Invitation destination'), findsOneWidget);
  });
  testWidgets('restore failure offers retry without signing out', (
    tester,
  ) async {
    var attempt = 0;
    await boot(
      tester,
      () => ++attempt == 1
          ? Stream.error(StateError('unavailable'))
          : Stream.value(true),
    );
    expect(find.text('Retry'), findsOneWidget);
    expect(find.text('Login destination'), findsNothing);
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(find.text('Dashboard destination'), findsOneWidget);
  });
}
