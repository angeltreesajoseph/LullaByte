import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lullabyte/features/baby_management/application/baby_profile_store.dart';
import 'package:lullabyte/features/growth/presentation/screens/growth_screen.dart';

void main() {
  Future<Map<String, List<Map<String, dynamic>>>> open(
    WidgetTester tester, {
    bool fail = false,
    List<Map<String, dynamic>> initial = const [],
  }) async {
    tester.view.physicalSize = const Size(430, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    BabyProfileStore.select({
      'id': 'a',
      'name': 'Anna',
      'birth_date': '2020-01-01',
      'birth_weight_kg': 3.2,
    });
    final rows = <String, List<Map<String, dynamic>>>{
      if (initial.isNotEmpty) 'a': initial,
    };
    final api = Dio();
    api.interceptors.add(
      InterceptorsWrapper(
        onRequest: (o, h) {
          final id = o.path.split('/')[2];
          if (o.method == 'GET') {
            h.resolve(
              Response(
                requestOptions: o,
                data: {
                  'data': {
                    'birth_date': '2020-01-01',
                    'tracker_data': {'growth': rows[id] ?? []},
                  },
                },
              ),
            );
          } else if (fail) {
            h.reject(
              DioException(
                requestOptions: o,
                type: DioExceptionType.connectionError,
              ),
            );
          } else {
            expect(o.path, contains('/trackers/growth'));
            rows[id] = (o.data as List)
                .map((r) => Map<String, dynamic>.from(r as Map))
                .toList();
            h.resolve(Response(requestOptions: o, data: {'data': rows[id]}));
          }
        },
      ),
    );
    await tester.pumpWidget(MaterialApp(home: GrowthScreen(api: api)));
    await tester.pumpAndSettle();
    return rows;
  }

  Future<void> tap(WidgetTester tester, String text) async {
    await tester.ensureVisible(find.text(text).last);
    await tester.pumpAndSettle();
    await tester.tap(find.text(text).last);
    await tester.pumpAndSettle();
  }

  testWidgets(
    'partial entries do not copy registration or previous measurements; twin isolation',
    (tester) async {
      final rows = await open(
        tester,
        initial: [
          {
            'id': 'old',
            'date': '2020-01-01',
            'weight': 3.5,
            'height': 50,
            'head': 30,
          },
        ],
      );
      await tester.enterText(
        find.byKey(const ValueKey('measurement_height')),
        '60',
      );
      await tester.enterText(find.byType(TextField).last, 'Measured at clinic');
      await tap(tester, 'Save measurement');
      expect(rows['a'], hasLength(2));
      expect(rows['a']!.first['weight'], isNull);
      expect(rows['a']!.first['head'], isNull);
      expect(rows['a']!.first['height'], 60);
      expect(rows['a']!.first['notes'], 'Measured at clinic');
      BabyProfileStore.select({'id': 'b', 'name': 'Ben'});
      await tester.pumpAndSettle();
      expect(find.text('Records for Ben'), findsOneWidget);
      expect(find.byTooltip('Edit measurement'), findsNothing);
      BabyProfileStore.select({'id': 'a', 'name': 'Anna'});
      await tester.pumpAndSettle();
      expect(find.byTooltip('Edit measurement'), findsNWidgets(2));
    },
  );
  testWidgets('empty and invalid measurements are rejected', (tester) async {
    final rows = await open(tester);
    await tap(tester, 'Save measurement');
    expect(find.text('Enter at least one measurement.'), findsOneWidget);
    await tester.enterText(
      find.byKey(const ValueKey('measurement_weight')),
      '0',
    );
    await tap(tester, 'Save measurement');
    expect(find.text('Enter a number greater than zero'), findsWidgets);
    expect(rows, isEmpty);
  });
  testWidgets('failed save retains input and does not create a record', (
    tester,
  ) async {
    final rows = await open(tester, fail: true);
    await tester.enterText(
      find.byKey(const ValueKey('measurement_weight')),
      '5.25',
    );
    await tap(tester, 'Save measurement');
    expect(find.text('5.25'), findsOneWidget);
    expect(find.textContaining('Your details are still here'), findsOneWidget);
    expect(rows, isEmpty);
  });
  testWidgets(
    'history holds all records; edit and delete update the saved list and chart',
    (tester) async {
      final rows = await open(
        tester,
        initial: List.generate(
          5,
          (i) => {
            'id': '$i',
            'date': DateTime.now()
                .subtract(Duration(days: i))
                .toIso8601String(),
            'weight': 5.0 - i * .1,
          },
        ),
      );
      expect(find.byTooltip('Edit measurement'), findsNWidgets(3));
      await tester.enterText(
        find.byKey(const ValueKey('measurement_weight')),
        '7',
      );
      await tap(tester, 'View all history');
      expect(find.byTooltip('Edit measurement'), findsNWidgets(5));
      await tester.ensureVisible(find.byTooltip('Edit measurement').first);
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Edit measurement').first);
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('measurement_weight')),
        '6',
      );
      await tap(tester, 'Save changes');
      expect(rows['a'], hasLength(5));
      expect(rows['a']!.first['weight'], 6);
      await tester.ensureVisible(find.byTooltip('Delete measurement').first);
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Delete measurement').first);
      await tester.pumpAndSettle();
      expect(rows['a'], hasLength(5));
      await tap(tester, 'Delete');
      expect(rows['a'], hasLength(4));
      Navigator.of(tester.element(find.text('Growth history'))).pop();
      await tester.pumpAndSettle();
      expect(find.text('7'), findsOneWidget);
      expect(find.byKey(const ValueKey('growth_point_0')), findsNothing);
    },
  );
  testWidgets('backdated measurement does not overwrite latest summary', (
    tester,
  ) async {
    final rows = await open(
      tester,
      initial: [
        {'id': 'latest', 'date': DateTime.now().toIso8601String(), 'weight': 6},
      ],
    );
    await tester.enterText(
      find.byKey(const ValueKey('measurement_weight')),
      '4',
    );
    await tester.tap(find.byKey(const ValueKey('measurement_date')));
    await tester.pumpAndSettle();
    tester
        .widget<CalendarDatePicker>(find.byType(CalendarDatePicker))
        .onDateChanged(DateTime(2020, 1, 1));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    await tap(tester, 'Save measurement');
    expect(rows['a'], hasLength(2));
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('growth_summary')),
        matching: find.text('6 kg'),
      ),
      findsOneWidget,
    );
  });
}
