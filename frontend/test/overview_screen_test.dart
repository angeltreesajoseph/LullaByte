import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lullabyte/features/baby_management/application/baby_profile_store.dart';
import 'package:lullabyte/features/trackers/domain/care_overview.dart';
import 'package:lullabyte/features/trackers/presentation/screens/trackers_screen.dart';
import 'package:lullabyte/features/trackers/presentation/widgets/care_bar_chart.dart';

void main() {
  testWidgets(
    'Overview replaces duplicate tabs, switches twins, exports same range and links history',
    (tester) async {
      tester.view.physicalSize = const Size(430, 1600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final babies = <Map<String, dynamic>>[
        {
          'id': 'a',
          'name': 'Anna',
          'tracker_data': {
            'feeding': [
              {
                'type': 'bottle',
                'occurred_at': DateTime.now().toIso8601String(),
                'amount_ml': 50,
              },
            ],
          },
        },
        {'id': 'b', 'name': 'Ben', 'tracker_data': {}},
      ];
      BabyProfileStore.select(babies.first);
      final api = Dio();
      api.interceptors.add(
        InterceptorsWrapper(
          onRequest: (o, h) =>
              h.resolve(Response(requestOptions: o, data: {'data': babies})),
        ),
      );
      CareOverview? exported;
      String? kind;
      DateTimeRange? range;
      await tester.pumpWidget(
        MaterialApp(
          home: TrackersScreen(
            api: api,
            onExport: (r) async {
              exported = r;
            },
            onHistory: (k, r) async {
              kind = k;
              range = r;
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Overview'), findsOneWidget);
      expect(find.text('Track'), findsNothing);
      expect(find.text('Reports'), findsNothing);
      expect(find.text('Feed count'), findsOneWidget);
      expect(find.byWidgetPredicate((w) => w is CareBarChart && w.series.unit == 'ml'), findsNothing);
      await tester.ensureVisible(find.text('Bottle volume'));
      await tester.tap(find.text('Bottle volume'));
      await tester.pumpAndSettle();
      expect(find.byWidgetPredicate((w) => w is CareBarChart && w.series.unit == 'ml'), findsOneWidget);
      await tester.tap(find.text('Feed count'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Monthly'));
      expect(find.text('Monthly'), findsOneWidget);
      await tester.tap(find.text('Weekly'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Preview / export care PDF'));
      await tester.pumpAndSettle();
      expect(exported!.name, 'Anna');
      expect(exported!.feeding, hasLength(1));
      expect(exported!.end.difference(exported!.start).inDays, 7);
      await tester.tap(find.text('View history').first);
      await tester.pumpAndSettle();
      expect(kind, 'feeding');
      expect(range!.start, exported!.start);
      await tester.ensureVisible(find.text('Ben'));
      await tester.tap(find.text('Ben'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Preview / export care PDF'));
      await tester.pumpAndSettle();
      expect(exported!.name, 'Ben');
      expect(exported!.feeding, isEmpty);
      expect(find.text('Report exported (demo)'), findsNothing);
    },
  );
}
