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
  for (final kind in ['feeding', 'sleep', 'diaper', 'growth']) {
    testWidgets(
      '$kind history accepts report range without leaking today into past range',
      (tester) async {
        tester.view.physicalSize = const Size(430, 1400);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        SharedPreferences.setMockInitialValues({});
        BabyProfileStore.select({
          'id': 'a',
          'name': 'Anna',
          'birth_date': '2020-01-01',
        });
        final old = DateTime.now().subtract(const Duration(days: 3));
        final dates = [old, DateTime.now()];
        final rows = [
          for (final day in dates)
            switch (kind) {
              'feeding' => {
                'type': 'bottle',
                'occurred_at': day.toIso8601String(),
                'amount_ml': 50,
              },
              'diaper' => {'type': 'wet', 'time': day.toIso8601String()},
              'growth' => {'date': day.toIso8601String(), 'weight': 4},
              _ => {
                'id': day.toIso8601String(),
                'type': 'nap',
                'start_at': day
                    .subtract(const Duration(hours: 1))
                    .toIso8601String(),
                'end_at': day.toIso8601String(),
              },
            },
        ];
        final api = Dio();
        api.interceptors.add(
          InterceptorsWrapper(
            onRequest: (o, h) => h.resolve(
              Response(
                requestOptions: o,
                data: {
                  'data': {
                    'birth_date': '2020-01-01',
                    'tracker_data': {kind: rows},
                  },
                },
              ),
            ),
          ),
        );
        final range = DateTimeRange(
          start: DateUtils.dateOnly(old),
          end: DateUtils.dateOnly(old),
        );
        final screen = switch (kind) {
          'feeding' => FeedingScreen(
            api: api,
            historyOnly: true,
            historyRange: range,
            syncReminders: (_, __, ___) async {},
          ),
          'diaper' => DiaperScreen(
            api: api,
            historyOnly: true,
            historyRange: range,
          ),
          'growth' => GrowthScreen(
            api: api,
            historyOnly: true,
            historyRange: range,
          ),
          _ => SleepScreen(api: api, historyOnly: true, historyRange: range),
        };
        await tester.pumpWidget(MaterialApp(home: screen));
        await tester.pumpAndSettle();
        final tooltip = switch (kind) {
          'feeding' => 'Edit feeding',
          'diaper' => 'Edit diaper change',
          'growth' => 'Edit measurement',
          _ => 'Edit sleep session',
        };
        expect(find.byTooltip(tooltip), findsOneWidget);
        await tester.tap(find.text('Today'));
        await tester.pumpAndSettle();
        expect(find.byTooltip(tooltip), findsOneWidget);
        await tester.tap(find.byTooltip('Show all dates'));
        await tester.pumpAndSettle();
        expect(find.byTooltip(tooltip), findsNWidgets(2));
      },
    );
  }
}
