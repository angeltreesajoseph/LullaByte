import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lullabyte/features/baby_management/application/baby_profile_store.dart';
import 'package:lullabyte/features/diaper/presentation/screens/diaper_screen.dart';

void main() {
  Future<Map<String, List<Map<String, dynamic>>>> open(
    WidgetTester tester, {
    bool fail = false,
    List<Map<String, dynamic>> initial = const [],
  }) async {
    tester.view.physicalSize = const Size(430, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    BabyProfileStore.select({
      'id': 'a',
      'name': 'Anna',
      'birth_date': '2026-01-01',
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
                    'birth_date': '2026-01-01',
                    'tracker_data': {'diaper': rows[id] ?? []},
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
            expect(o.path, contains('/trackers/diaper'));
            rows[id] = (o.data as List)
                .map((r) => Map<String, dynamic>.from(r as Map))
                .toList();
            h.resolve(Response(requestOptions: o, data: {'data': rows[id]}));
          }
        },
      ),
    );
    await tester.pumpWidget(MaterialApp(home: DiaperScreen(api: api)));
    await tester.pumpAndSettle();
    return rows;
  }

  Future<void> save(WidgetTester tester) async {
    await tester.ensureVisible(find.text('Save change'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save change'));
    await tester.pumpAndSettle();
  }

  testWidgets(
    'inline wet entry saves notes without an invented stool colour; twin isolation',
    (tester) async {
      final rows = await open(tester);
      expect(find.text('Stool colour (optional)'), findsNothing);
      await tester.enterText(find.byType(TextField), 'Comfortable change');
      await save(tester);
      expect(rows['a'], hasLength(1));
      expect(rows['a']!.single['type'], 'wet');
      expect(rows['a']!.single['color'], isNull);
      expect(rows['a']!.single['notes'], 'Comfortable change');
      expect(DateTime.tryParse(rows['a']!.single['time']), isNotNull);
      BabyProfileStore.select({'id': 'b', 'name': 'Ben'});
      await tester.pumpAndSettle();
      expect(find.text('Records for Ben'), findsOneWidget);
      expect(find.byTooltip('Edit diaper change'), findsNothing);
      BabyProfileStore.select({'id': 'a', 'name': 'Anna'});
      await tester.pumpAndSettle();
      expect(find.byTooltip('Edit diaper change'), findsOneWidget);
    },
  );
  testWidgets(
    'dirty colour optional and switching back to wet clears persisted colour',
    (tester) async {
      final rows = await open(tester);
      await tester.tap(find.byKey(const ValueKey('diaper_type_dirty')));
      await tester.pumpAndSettle();
      expect(find.text('Stool colour (optional)'), findsOneWidget);
      await tester.tap(find.text('Green'));
      await save(tester);
      expect(rows['a']!.single['color'], 'Green');
      await tester.ensureVisible(find.byKey(const ValueKey('diaper_type_wet')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('diaper_type_wet')));
      await tester.pumpAndSettle();
      await save(tester);
      expect(rows['a']!.first['type'], 'wet');
      expect(rows['a']!.first['color'], isNull);
    },
  );
  testWidgets('save failure retains inputs and does not add a false record', (
    tester,
  ) async {
    final rows = await open(tester, fail: true);
    await tester.enterText(find.byType(TextField), 'Keep this note');
    await save(tester);
    expect(find.text('Keep this note'), findsOneWidget);
    expect(find.textContaining('Your details are still here'), findsOneWidget);
    expect(rows, isEmpty);
  });
  testWidgets(
    'recent three, full history, date filters and draft preservation',
    (tester) async {
      await open(
        tester,
        initial: List.generate(
          5,
          (i) => {
            'type': 'wet',
            'color': 'Yellow',
            'time': DateTime.now()
                .subtract(Duration(minutes: i))
                .toIso8601String(),
          },
        ),
      );
      expect(find.byTooltip('Edit diaper change'), findsNWidgets(3));
      expect(find.text('Insights'), findsNothing);
      expect(find.text('Weekly Pattern'), findsNothing);
      expect(find.text('Current Status'), findsNothing);
      expect(
        tester.getSize(find.byKey(const ValueKey('diaper_summary'))).height,
        lessThan(160),
      );
      await tester.enterText(find.byType(TextField), 'Draft note');
      await tester.ensureVisible(find.text('View all history'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('View all history'));
      await tester.pumpAndSettle();
      expect(find.text('Diaper history'), findsOneWidget);
      expect(find.byType(TextField), findsNothing);
      expect(find.byTooltip('Edit diaper change'), findsNWidgets(5));
      expect(find.text('All dates'), findsOneWidget);
      await tester.tap(find.text('Today'));
      await tester.pumpAndSettle();
      expect(find.byTooltip('Edit diaper change'), findsNWidgets(5));
      Navigator.of(tester.element(find.text('Diaper history'))).pop();
      await tester.pumpAndSettle();
      expect(find.text('Draft note'), findsOneWidget);
    },
  );
  testWidgets('edit replaces existing record and delete needs confirmation', (
    tester,
  ) async {
    final rows = await open(
      tester,
      initial: [
        {
          'type': 'mixed',
          'color': 'Brown',
          'time': DateTime.now().toIso8601String(),
          'notes': 'Original',
        },
      ],
    );
    await tester.ensureVisible(find.byTooltip('Edit diaper change'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Edit diaper change'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Updated');
    await tester.ensureVisible(find.text('Save changes'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save changes'));
    await tester.pumpAndSettle();
    expect(rows['a'], hasLength(1));
    expect(rows['a']!.single['notes'], 'Updated');
    await tester.ensureVisible(find.byTooltip('Delete diaper change'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Delete diaper change'));
    await tester.pumpAndSettle();
    expect(rows['a'], hasLength(1));
    await tester.tap(find.text('Delete').last);
    await tester.pumpAndSettle();
    expect(rows['a'], isEmpty);
  });
  testWidgets('future-dated changes cannot be saved', (tester) async {
    final initial = {
      'type': 'wet',
      'time': DateTime.now().add(const Duration(days: 1)).toIso8601String(),
    };
    final rows = await open(tester, initial: [initial]);
    await tester.ensureVisible(find.byTooltip('Edit diaper change'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Edit diaper change'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Save changes'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save changes'));
    await tester.pumpAndSettle();
    expect(find.text('Choose a date from birth through now.'), findsOneWidget);
    expect(rows['a']!.single, initial);
  });
}
