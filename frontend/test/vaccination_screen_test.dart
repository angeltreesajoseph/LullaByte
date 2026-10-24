import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lullabyte/features/baby_management/application/baby_profile_store.dart';
import 'package:lullabyte/features/vaccination/presentation/screens/vaccination_screen.dart';
import 'package:lullabyte/features/vaccination/presentation/widgets/vaccination_cards.dart';

void main() {
  Future<List<List<Map<String, dynamic>>>> open(
    WidgetTester tester, {
    bool fail = false,
  }) async {
    tester.view.physicalSize = const Size(430, 1100);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    BabyProfileStore.id = 'test-baby';
    BabyProfileStore.name = 'Chris';
    final requests = <List<Map<String, dynamic>>>[];
    final api = Dio();
    api.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (options.method == 'GET') {
            handler.resolve(
              Response(
                requestOptions: options,
                data: {
                  'data': {
                    'id': 'test-baby',
                    'name': 'Chris',
                    'birth_date': '2026-01-01',
                    'tracker_data': {},
                  },
                },
              ),
            );
          } else {
            final rows = (options.data as List)
                .map((e) => Map<String, dynamic>.from(e as Map))
                .toList();
            requests.add(rows);
            if (fail) {
              handler.reject(
                DioException.badResponse(
                  statusCode: 400,
                  requestOptions: options,
                  response: Response(
                    requestOptions: options,
                    statusCode: 400,
                    data: {
                      'error': {'message': 'Unknown tracker'},
                    },
                  ),
                ),
              );
            } else {
              handler.resolve(
                Response(requestOptions: options, data: {'data': rows}),
              );
            }
          }
        },
      ),
    );
    await tester.pumpWidget(
      MaterialApp(
        home: VaccinationScreen(api: api, syncReminders: (_) async {}),
      ),
    );
    await tester.pumpAndSettle();
    return requests;
  }

  testWidgets('checkbox records completion directly without opening calendar', (
    tester,
  ) async {
    final writes = await open(tester);
    final check = find.byType(Checkbox).first;
    final selectedId = tester
        .widget<VaccinationDoseCard>(find.byType(VaccinationDoseCard).first)
        .entry['id'];
    await tester.ensureVisible(check);
    await tester.tap(check);
    await tester.pumpAndSettle();
    expect(find.byType(DatePickerDialog), findsNothing);
    expect(writes, hasLength(1));
    expect(writes.last.first['done'], true);
    final actual = DateTime.parse(writes.last.first['received_date']);
    expect(DateUtils.isSameDay(actual, DateTime.now()), true);
    final matching = tester
        .widgetList<VaccinationDoseCard>(find.byType(VaccinationDoseCard))
        .where((c) => c.entry['id'] == selectedId)
        .toList();
    expect(matching, hasLength(1));
    expect(matching.single.entry['done'], true);
    expect(
      tester
          .widget<VaccinationDoseCard>(find.byType(VaccinationDoseCard).first)
          .entry['done'],
      true,
    );
    expect(tester.widget<Checkbox>(find.byType(Checkbox).first).value, true);
    await Scrollable.ensureVisible(
      tester.element(find.byType(Checkbox).first),
      alignment: 0.5,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byType(Checkbox).first);
    await tester.pumpAndSettle();
    expect(writes.last.first['done'], false);
    expect(writes.last.first['received_date'], null);
    expect(find.byType(AlertDialog), findsNothing);
  });
  testWidgets('failed save rolls checkbox back and shows deployment error', (
    tester,
  ) async {
    await open(tester, fail: true);
    await tester.ensureVisible(find.byType(Checkbox).first);
    await tester.tap(find.byType(Checkbox).first);
    await tester.pumpAndSettle();
    expect(tester.widget<Checkbox>(find.byType(Checkbox).first).value, false);
    expect(find.textContaining('not enabled on this server'), findsWidgets);
  });
  testWidgets('failed form save keeps entered details for retry', (
    tester,
  ) async {
    await open(tester, fail: true);
    await tester.ensureVisible(find.text('Add vaccination'));
    await tester.tap(find.text('Add vaccination'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byType(TextFormField).first,
      'Custom vaccine dose 1',
    );
    await tester.ensureVisible(find.text('Save vaccination'));
    await tester.tap(find.text('Save vaccination'));
    await tester.pumpAndSettle();
    expect(find.text('Custom vaccine dose 1'), findsOneWidget);
    expect(find.textContaining('Your details are still here'), findsOneWidget);
  });
  testWidgets(
    'reminder button opens its editor and cancel makes no saved change',
    (tester) async {
      final writes = await open(tester);
      await tester.ensureVisible(find.text('Set reminder').first);
      await tester.tap(find.text('Set reminder').first);
      await tester.pumpAndSettle();
      expect(find.text('A gentle reminder'), findsOneWidget);
      expect(find.text('Save reminder'), findsOneWidget);
      expect(find.byType(DatePickerDialog), findsNothing);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(writes, isEmpty);
    },
  );
}
