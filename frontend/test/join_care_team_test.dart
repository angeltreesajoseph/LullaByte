import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:lullabyte/core/router/route_paths.dart';
import 'package:lullabyte/features/family_sharing/presentation/widgets/join_care_team_card.dart';
import 'package:lullabyte/features/family_sharing/presentation/screens/family_sharing_screen.dart';
import 'package:lullabyte/features/family_sharing/application/shared_care_connection.dart';
import 'package:lullabyte/features/baby_management/application/baby_profile_store.dart';

void main() {
  testWidgets('join entry opens invitation flow without registration', (
    tester,
  ) async {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => const Scaffold(body: JoinCareTeamCard()),
        ),
        GoRoute(
          path: RoutePaths.familySharing,
          builder: (_, s) => Scaffold(
            body: Text('Join mode: ${s.uri.queryParameters['join']}'),
          ),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.tap(find.text('Join a baby’s care team'));
    await tester.pumpAndSettle();
    expect(find.text('Join mode: true'), findsOneWidget);
  });

  testWidgets(
    'caretaker with no baby pastes link, accepts and opens shared dashboard',
    (tester) async {
      tester.view.physicalSize = const Size(390, 740);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      PendingCareInvitation.id = null;
      addTearDown(() => PendingCareInvitation.id = null);
      const id = '10000000-0000-4000-8000-000000000001';
      var accepted = false;
      final writes = <String>[];
      final api = Dio();
      api.interceptors.add(
        InterceptorsWrapper(
          onRequest: (o, h) {
            dynamic data;
            if (o.method == 'POST') {
              writes.add(o.path);
              expect(o.path, '/sharing/$id/accept');
              accepted = true;
              data = {};
            } else if (o.path == '/babies') {
              data = accepted
                  ? [
                      {
                        'id': 'shared',
                        'name': 'Anna',
                        'access_role': 'caregiver',
                      },
                    ]
                  : [];
            } else {
              data = [
                {
                  'id': id,
                  'baby_id': 'shared',
                  'baby_name': 'Anna',
                  'email': 'care@example.com',
                  'role': 'caregiver',
                  'status': accepted ? 'accepted' : 'pending',
                  'expires_at': '2099-01-01T00:00:00Z',
                  'is_owner': false,
                },
              ];
            }
            h.resolve(Response(requestOptions: o, data: {'data': data}));
          },
        ),
      );
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (_, _) => FamilySharingScreen(api: api, joinMode: true),
          ),
          GoRoute(
            path: RoutePaths.dashboard,
            builder: (_, _) =>
                const Scaffold(body: Text('Shared baby dashboard')),
          ),
        ],
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();
      expect(find.text('Invitation link or code'), findsOneWidget);
      expect(
        tester
            .widget<FilledButton>(
              find.widgetWithText(FilledButton, 'Open baby dashboard'),
            )
            .onPressed,
        isNull,
      );
      expect(find.text('1. Verify your email'), findsOneWidget);
      expect(find.text('2. Accept the invitation'), findsOneWidget);
      expect(find.text('3. Open the baby profile'), findsOneWidget);
      final scroll = tester.state<ScrollableState>(
        find.descendant(
          of: find.byKey(const ValueKey('join_steps_scroll')),
          matching: find.byType(Scrollable),
        ).first,
      );
      expect(scroll.position.maxScrollExtent, 0);
      await tester.enterText(
        find.byType(TextField),
        'https://lullabyte-api.onrender.com/join/$id',
      );
      await tester.tap(find.text('Review invitation'));
      await tester.pumpAndSettle();
      expect(find.text('Join Anna’s care team?'), findsOneWidget);
      await tester.tap(find.widgetWithText(FilledButton, 'Accept'));
      await tester.pumpAndSettle();
      expect(writes, hasLength(1));
      expect(BabyProfileStore.id, 'shared');
      await tester.tap(find.text('Open baby dashboard'));
      await tester.pumpAndSettle();
      expect(find.text('Shared baby dashboard'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
