import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:lullabyte/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:lullabyte/features/baby_management/application/baby_profile_store.dart';

void main() {
  setUp(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    BabyProfileStore.babies = [];
    BabyProfileStore.select({});
  });
  testWidgets(
    'loading is not mistaken for an empty account and dependency changes do not refetch',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetDevicePixelRatio);
      var reads = 0;
      RequestOptions? pending;
      RequestInterceptorHandler? answer;
      final api = Dio();
      api.interceptors.add(
        InterceptorsWrapper(
          onRequest: (o, h) {
            if (o.path == '/babies') {
              reads++;
              pending = o;
              answer = h;
            } else {
              h.resolve(
                Response(
                  requestOptions: o,
                  data: {
                    'data': {'unread_count': 0},
                  },
                ),
              );
            }
          },
        ),
      );
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (_, _) => DashboardScreen(api: api),
          ),
        ],
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('Loading baby profiles…'), findsOneWidget);
      expect(find.text('No baby profiles yet'), findsNothing);
      expect(find.text('Join a baby’s care team'), findsNothing);
      tester.view.physicalSize = const Size(440, 1000);
      addTearDown(tester.view.resetPhysicalSize);
      await tester.pump();
      expect(reads, 1);
      answer!.resolve(
        Response(
          requestOptions: pending!,
          data: {
            'data': [
              {'id': 'one', 'name': 'Anna', 'access_role': 'owner'},
            ],
          },
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('Loading baby profiles…'), findsNothing);
      expect(BabyProfileStore.id, 'one');
      expect(reads, 1);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    },
  );
  testWidgets('failed load offers retry instead of a silent blank profile', (
    tester,
  ) async {
    var reads = 0;
    final api = Dio();
    api.interceptors.add(
      InterceptorsWrapper(
        onRequest: (o, h) {
          if (o.path == '/babies') {
            reads++;
            h.reject(
              DioException(
                requestOptions: o,
                type: DioExceptionType.connectionError,
              ),
            );
          } else {
            h.resolve(
              Response(
                requestOptions: o,
                data: {
                  'data': {'unread_count': 0},
                },
              ),
            );
          }
        },
      ),
    );
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => DashboardScreen(api: api),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pump(const Duration(seconds: 2));
    await tester.pump();
    expect(
      find.text('Could not load profiles (connectionError). Tap Retry.'),
      findsOneWidget,
    );
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text('Retry'));
    for (var frame = 0; frame < 5; frame++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(reads, 2);
    expect(find.text('Join a baby’s care team'), findsNothing);
    await tester.pumpWidget(const SizedBox());
  });
}
