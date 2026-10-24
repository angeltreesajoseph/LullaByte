import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lullabyte/features/baby_management/application/baby_profile_store.dart';
import 'package:lullabyte/features/sleep/presentation/screens/sleep_screen.dart';

class _Harness {
  final api = Dio();
  final rows = <String, List<Map<String, dynamic>>>{};
  bool fail = false;
  DateTime now = DateTime.now().add(const Duration(minutes: 1));
  _Harness() {
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
                    'tracker_data': {'sleep': rows[id] ?? []},
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
            expect(o.path, contains('/trackers/sleep'));
            rows[id] = (o.data as List)
                .map((r) => Map<String, dynamic>.from(r as Map))
                .toList();
            h.resolve(Response(requestOptions: o, data: {'data': rows[id]}));
          }
        },
      ),
    );
  }
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  Future<_Harness> open(
    WidgetTester tester, {
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
    });
    final h = _Harness();
    if (initial.isNotEmpty) h.rows['a'] = initial;
    await tester.pumpWidget(
      MaterialApp(
        home: SleepScreen(api: h.api, now: () => h.now),
      ),
    );
    await tester.pumpAndSettle();
    return h;
  }

  Future<void> tap(WidgetTester tester, String text) async {
    await tester.ensureVisible(find.text(text).last);
    await tester.pumpAndSettle();
    await tester.tap(find.text(text).last);
    await tester.pumpAndSettle();
  }

  final historyReference=DateTime.now();
  Map<String, dynamic> session(int i) => {
    'id': '$i',
    'type': 'nap',
    'record_type': 'session',
    'start_at': historyReference
        .subtract(Duration(hours: i + 2))
        .toUtc()
        .toIso8601String(),
    'end_at': historyReference
        .subtract(Duration(hours: i + 1))
        .toUtc()
        .toIso8601String(),
    'notes': 'Session $i',
  };
  testWidgets(
    'timer start persists, twins run independently, completed session enters history',
    (tester) async {
      final h = await open(tester);
      await tap(tester, 'Start sleep');
      expect(h.rows['a']!.single['record_type'], 'active');
      expect(find.byTooltip('Edit sleep session'), findsNothing);
      h.now = h.now.add(const Duration(minutes: 20));
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('20 min'), findsOneWidget);
      BabyProfileStore.select({'id': 'b', 'name': 'Ben'});
      await tester.pumpAndSettle();
      expect(find.text('Start sleep'), findsOneWidget);
      await tap(tester, 'Start sleep');
      expect(h.rows['b']!.single['record_type'], 'active');
      BabyProfileStore.select({'id': 'a', 'name': 'Anna'});
      await tester.pumpAndSettle();
      expect(find.text('20 min'), findsOneWidget);
      await tap(tester, 'Stop and save');
      expect(h.rows['a']!.single['record_type'], 'session');
      expect(h.rows['b']!.single['record_type'], 'active');
      expect(find.byTooltip('Edit sleep session'), findsOneWidget);
    },
  );
  testWidgets(
    'active timer and pending stop survive reopening; retry preserves stop time',
    (tester) async {
      final h = await open(tester);
      await tap(tester, 'Start sleep');
      h.now = h.now.add(const Duration(minutes: 15));
      h.fail = true;
      await tap(tester, 'Stop and save');
      expect(find.text('Retry saving sleep'), findsOneWidget);
      expect(h.rows['a']!.single['record_type'], 'active');
      final stopped = h.now;
      await tester.pumpWidget(const SizedBox.shrink());
      h.now = h.now.add(const Duration(minutes: 10));
      await tester.pumpWidget(
        MaterialApp(
          home: SleepScreen(api: h.api, now: () => h.now),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Retry saving sleep'), findsOneWidget);
      expect(find.text('15 min'), findsOneWidget);
      h.fail = false;
      await tap(tester, 'Retry saving sleep');
      expect(DateTime.parse(h.rows['a']!.single['end_at']), stopped.toUtc());
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.containsKey('sleep_stop/test-owner/a'), false);
    },
  );
  testWidgets(
    'manual past sleep saves dates and notes; overlaps are rejected',
    (tester) async {
      final h = await open(tester);
      await tap(tester, 'Add past sleep');
      await tester.enterText(find.byType(TextField), 'Restful nap');
      await tap(tester, 'Save past sleep');
      expect(h.rows['a'], hasLength(1));
      expect(h.rows['a']!.single['notes'], 'Restful nap');
      expect(h.rows['a']!.single['start_at'], isNotNull);
      expect(h.rows['a']!.single['end_at'], isNotNull);
      await tap(tester, 'Save past sleep');
      expect(h.rows['a'], hasLength(1));
      expect(find.textContaining('overlaps another sleep'), findsOneWidget);
    },
  );
  testWidgets(
    'manual failure keeps details; failed start does not create a timer',
    (tester) async {
      final h = await open(tester);
      h.fail = true;
      await tap(tester, 'Start sleep');
      expect(find.text('Start sleep'), findsOneWidget);
      expect(h.rows, isEmpty);
      await tap(tester, 'Add past sleep');
      await tester.enterText(find.byType(TextField), 'Keep my notes');
      await tap(tester, 'Save past sleep');
      expect(find.text('Keep my notes'), findsOneWidget);
      expect(
        find.textContaining('Your details are still here'),
        findsOneWidget,
      );
      expect(h.rows, isEmpty);
    },
  );
  testWidgets(
    'recent three and full history; edit/delete and drafts remain connected',
    (tester) async {
      final h = await open(tester, initial: List.generate(5, session));
      expect(find.byTooltip('Edit sleep session'), findsNWidgets(3));
      expect(find.text('Weekly Sleep Trend'), findsNothing);
      expect(find.text('Insights'), findsNothing);
      await tap(tester, 'Add past sleep');
      await tester.enterText(find.byType(TextField), 'Draft note');
      await tap(tester, 'View all history');
      expect(find.text('Sleep history'), findsOneWidget);
      expect(find.byTooltip('Edit sleep session'), findsNWidgets(5));
      await tester.ensureVisible(find.byTooltip('Edit sleep session').first);
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Edit sleep session').first);
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Updated');
      await tap(tester, 'Save changes');
      expect(h.rows['a'], hasLength(5));
      expect(h.rows['a']!.first['notes'], 'Updated');
      await tester.ensureVisible(find.byTooltip('Delete sleep session').first);
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Delete sleep session').first);
      await tester.pumpAndSettle();
      expect(h.rows['a'], hasLength(5));
      await tap(tester, 'Delete');
      expect(h.rows['a'], hasLength(4));
      Navigator.of(tester.element(find.text('Sleep history'))).pop();
      await tester.pumpAndSettle();
      expect(find.text('Draft note'), findsOneWidget);
    },
  );
}
