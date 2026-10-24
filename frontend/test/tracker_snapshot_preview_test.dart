import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lullabyte/features/baby_management/application/baby_profile_store.dart';
import 'package:lullabyte/features/feeding/presentation/screens/feeding_screen.dart';
import 'package:lullabyte/features/sleep/presentation/screens/sleep_screen.dart';
import 'package:lullabyte/features/diaper/presentation/screens/diaper_screen.dart';
import 'package:lullabyte/features/growth/presentation/screens/growth_screen.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  test('snapshot reuse requires the selected baby and server revisions', () {
    BabyProfileStore.select({'id': 'one', 'name': 'Anna', 'tracker_data': {}});
    expect(BabyProfileStore.snapshotFor('one'), isNull);
    BabyProfileStore.select({
      'id': 'one',
      'name': 'Anna',
      'tracker_data': {},
      'tracker_revisions': {},
    });
    expect(BabyProfileStore.snapshotFor('one'), isNotNull);
    expect(BabyProfileStore.snapshotFor('two'), isNull);
    BabyProfileStore.select({});
    expect(BabyProfileStore.snapshotFor('one'), isNull);
  });
  for (final kind in ['feeding', 'sleep', 'diaper', 'growth']) {
    testWidgets(
      '$kind shows session records before a delayed network response',
      (tester) async {
        tester.view.physicalSize = const Size(430, 1500);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final snapshot = <String, dynamic>{
          'id': 'one',
          'name': 'Anna',
          'birth_date': '2020-01-01',
          'access_role': 'owner',
          'tracker_data': {kind: []},
          'tracker_revisions': {kind: 'loaded'},
        };
        BabyProfileStore.select(snapshot);
        RequestOptions? request;
        RequestInterceptorHandler? reply;
        final api = Dio();
        api.interceptors.add(
          InterceptorsWrapper(
            onRequest: (o, h) {
              request = o;
              reply = h;
            },
          ),
        );
        final widget = switch (kind) {
          'feeding' => FeedingScreen(
            api: api,
            syncReminders: (_, _, _) async {},
          ),
          'sleep' => SleepScreen(api: api),
          'diaper' => DiaperScreen(api: api),
          _ => GrowthScreen(api: api),
        };
        await tester.pumpWidget(MaterialApp(home: widget));
        await tester.pump(const Duration(milliseconds: 100));
        expect(find.byType(CircularProgressIndicator), findsNothing);
        expect(find.byType(LinearProgressIndicator), findsOneWidget);
        expect(BabyProfileStore.name, 'Anna');
        reply!.resolve(
          Response(requestOptions: request!, data: {'data': snapshot}),
        );
        await tester.pumpAndSettle();
        expect(find.byType(LinearProgressIndicator), findsNothing);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
      },
    );
  }
}
