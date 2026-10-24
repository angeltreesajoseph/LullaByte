import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lullabyte/features/baby_management/application/baby_profile_store.dart';
import 'package:lullabyte/features/feeding/presentation/screens/feeding_screen.dart';

void main() {
  Future<Map<String, List<Map<String, dynamic>>>> open(
    WidgetTester tester, {
    bool fail = false,
    List<Map<String, dynamic>> initialRows = const [],
  }) async {
    tester.view.physicalSize = const Size(430, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    BabyProfileStore.select({
      'id': 'baby-a',
      'name': 'Anna',
      'birth_date': '2026-01-01',
    });
    final records = <String, List<Map<String, dynamic>>>{
      if (initialRows.isNotEmpty) 'baby-a': initialRows,
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
                    'tracker_data': {'feeding': records[id] ?? []},
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
            records[id] = (o.data as List)
                .map((r) => Map<String, dynamic>.from(r as Map))
                .toList();
            h.resolve(Response(requestOptions: o, data: {'data': records[id]}));
          }
        },
      ),
    );
    await tester.pumpWidget(
      MaterialApp(
        home: FeedingScreen(
          api: api,
          syncReminders: (_, __, ___) async {},
          requestPermission: () async => true,
        ),
      ),
    );
    await tester.pumpAndSettle();
    return records;
  }

  Future<void> add(WidgetTester tester) async {
    expect(find.byType(TextFormField), findsWidgets);
    await tester.enterText(find.byType(TextFormField).first, '85');
    await tester.enterText(
      find.byType(TextFormField).last,
      'Finished comfortably',
    );
    await tester.ensureVisible(find.text('Save feeding'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save feeding'));
    await tester.pumpAndSettle();
  }

  testWidgets(
    'saves structured quantities and notes; twin switching stays isolated',
    (tester) async {
      final records = await open(tester);
      await add(tester);
      expect(records['baby-a']!.single['amount_ml'], 85);
      expect(records['baby-a']!.single['notes'], 'Finished comfortably');
      expect(records['baby-a']!.single['occurred_at'], isNotNull);
      expect(find.text('85 ml'), findsOneWidget);
      BabyProfileStore.select({'id': 'baby-b', 'name': 'Ben'});
      await tester.pumpAndSettle();
      expect(find.text('Records for Ben'), findsOneWidget);
      expect(find.text('0 ml'), findsOneWidget);
      expect(records['baby-b'], isNull);
      BabyProfileStore.select({'id': 'baby-a', 'name': 'Anna'});
      await tester.pumpAndSettle();
      expect(find.text('85 ml'), findsOneWidget);
    },
  );
  testWidgets('compact summary, inline form and full history work together', (
    tester,
  ) async {
    await open(
      tester,
      initialRows: List.generate(
        5,
        (i) => {
          'id': '$i',
          'type': 'bottle',
          'amount_ml': 10,
          'occurred_at': DateTime.now()
              .subtract(Duration(minutes: i))
              .toUtc()
              .toIso8601String(),
        },
      ),
    );
    expect(find.byType(TextFormField), findsNWidgets(2));
    expect(
      tester.getSize(find.byKey(const ValueKey('feeding_summary'))).height,
      lessThan(160),
    );
    expect(find.byTooltip('Edit feeding'), findsNWidgets(3));
    await tester.enterText(find.byType(TextFormField).first, '42');
    final history = find.text('View all history');
    await tester.ensureVisible(history);
    await tester.pumpAndSettle();
    await tester.tap(history);
    await tester.pumpAndSettle();
    expect(find.text('Feeding history'), findsOneWidget);
    expect(find.byType(TextFormField), findsNothing);
    expect(find.byTooltip('Edit feeding'), findsNWidgets(5));
    expect(find.text('Today'), findsOneWidget);
    Navigator.of(tester.element(find.text('Feeding history'))).pop();
    await tester.pumpAndSettle();
    expect(find.text('42'), findsOneWidget);
    expect(find.byTooltip('Edit feeding'), findsNWidgets(3));
  });
  testWidgets('multiple reminder cards can be added, edited and deleted', (
    tester,
  ) async {
    final records = await open(tester);
    Future<void> chooseTime() async {
      await tester.pumpAndSettle();
      tester
          .widget<CalendarDatePicker>(find.byType(CalendarDatePicker))
          .onDateChanged(
            DateUtils.dateOnly(DateTime.now().add(const Duration(days: 2))),
          );
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK').last);
      await tester.pumpAndSettle();
    }

    for (var i = 0; i < 2; i++) {
      expect(find.text('Add reminder'), findsOneWidget);
      await tester.ensureVisible(find.text('Add reminder'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Add reminder'));
      await chooseTime();
    }
    expect(records['baby-a'], hasLength(2));
    expect(records['baby-a']![0]['id'], isNot(records['baby-a']![1]['id']));
    expect(find.byTooltip('Edit reminder'), findsNWidgets(2));
    final other = Map<String, dynamic>.from(records['baby-a']!.last);
    await tester.ensureVisible(find.byTooltip('Edit reminder').first);
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Edit reminder').first);
    await chooseTime();
    expect(records['baby-a'], hasLength(2));
    expect(records['baby-a']!.last, other);
    await tester.ensureVisible(find.byTooltip('Delete reminder').first);
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Delete reminder').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete').last);
    await tester.pumpAndSettle();
    expect(records['baby-a'], hasLength(1));
    expect(records['baby-a']!.single, other);
  });
  testWidgets('solids count is shown and history has no Undated filter', (
    tester,
  ) async {
    await open(
      tester,
      initialRows: [
        {
          'type': 'solids',
          'food': 'Puree',
          'occurred_at': DateTime.now().toUtc().toIso8601String(),
        },
        {'type': 'bottle', 'amount': '30 ml'},
      ],
    );
    expect(find.text('solids'), findsOneWidget);
    await tester.ensureVisible(find.text('View all history'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('View all history'));
    await tester.pumpAndSettle();
    expect(find.text('Undated'), findsNothing);
    expect(find.text('All dates'), findsOneWidget);
    expect(find.byTooltip('Edit feeding'), findsNWidgets(2));
  });
  testWidgets('save failure keeps entered fields and no false saved record', (
    tester,
  ) async {
    final records = await open(tester, fail: true);
    await add(tester);
    expect(find.text('85'), findsOneWidget);
    expect(find.text('Finished comfortably'), findsOneWidget);
    expect(find.textContaining('Your details are still here'), findsOneWidget);
    expect(records, isEmpty);
  });
  testWidgets('fields change with feeding type; placeholders removed', (
    tester,
  ) async {
    await open(tester);
    expect(find.text('Insights'), findsNothing);
    expect(find.text('Daily Intake'), findsNothing);
    await tester.tap(find.text('Breastfeed'));
    await tester.pumpAndSettle();
    expect(find.text('Duration (minutes)'), findsWidgets);
    expect(find.text('Amount consumed (ml)'), findsNothing);
    expect(find.text('Left'), findsOneWidget);
    await tester.tap(find.text('Solids'));
    await tester.pumpAndSettle();
    expect(find.text('Food name'), findsWidgets);
    expect(find.text('Duration (minutes)'), findsNothing);
  });
  testWidgets('delete requires confirmation and persists removal', (
    tester,
  ) async {
    final records = await open(tester);
    await add(tester);
    final delete = find.byTooltip('Delete feeding');
    await tester.ensureVisible(delete);
    await tester.pumpAndSettle();
    await tester.tap(delete);
    await tester.pumpAndSettle();
    expect(records['baby-a'], hasLength(1));
    await tester.tap(find.text('Delete').last);
    await tester.pumpAndSettle();
    expect(records['baby-a'], isEmpty);
  });
  testWidgets('edit replaces a saved record instead of duplicating it', (
    tester,
  ) async {
    final records = await open(tester);
    await add(tester);
    final edit = find.byTooltip('Edit feeding');
    await tester.ensureVisible(edit);
    await tester.pumpAndSettle();
    await tester.tap(edit);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, '100');
    await tester.ensureVisible(find.text('Save feeding'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save feeding'));
    await tester.pumpAndSettle();
    expect(records['baby-a'], hasLength(1));
    expect(records['baby-a']!.single['amount_ml'], 100);
    expect(records['baby-a']!.single['notes'], 'Finished comfortably');
  });
}
