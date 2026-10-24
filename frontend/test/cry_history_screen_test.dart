import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lullabyte/features/baby_management/application/baby_profile_store.dart';
import 'package:lullabyte/features/cry_analyzer/application/cry_history_playback.dart';
import 'package:lullabyte/features/cry_analyzer/domain/cry_history_records.dart';
import 'package:lullabyte/features/cry_analyzer/presentation/screens/cry_history_screen.dart';

class _Playback extends CryHistoryPlayback {
  String? key;
  bool running = false, disposed = false, fail = false;
  int toggles = 0, stops = 0;
  @override
  String? get currentKey => key;
  @override
  bool get playing => running;
  @override
  Duration get position => const Duration(seconds: 1);
  @override
  Duration get duration => const Duration(seconds: 2);
  @override
  Future<void> toggle(Map<String, dynamic> row) async {
    if (fail) throw StateError('Cannot play');
    toggles++;
    final next = CryHistoryRecords.key(row);
    running = key == next ? !running : true;
    key = next;
    notifyListeners();
  }

  @override
  Future<void> stop() async {
    stops++;
    key = null;
    running = false;
    notifyListeners();
  }

  @override
  void dispose() {
    disposed = true;
    super.dispose();
  }
}

void main() {
  Future<Map<String, List<Map<String, dynamic>>>> open(
    WidgetTester tester,
    _Playback player, {
    bool fail = false,
    bool analyzed = false,
    DateTimeRange? range,
  }) async {
    tester.view.physicalSize = const Size(430, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    BabyProfileStore.select({'id': 'a', 'name': 'Anna'});
    final rows = <String, List<Map<String, dynamic>>>{
      'a': [
        {
          'time': DateTime.now().toIso8601String(),
          'format': 'wav',
          'audio_data': 'AA==',
          'result': 'Analysis unavailable',
          if (analyzed) ...{
            'mode': 'experimental',
            'label': 'hungry',
            'scores': {'hungry': 70.0, 'tired': 30.0},
            'tip': 'Saved care suggestion',
          },
        },
        {
          'time': DateTime.now()
              .subtract(const Duration(days: 1))
              .toIso8601String(),
          'format': 'mp3',
          'audio_data': 'AA==',
          'result': 'Analysis unavailable',
        },
      ],
    };
    final api = Dio();
    api.interceptors.add(
      InterceptorsWrapper(
        onRequest: (o, h) {
          final id = o.path.split('/')[2];
          if (o.method == 'GET')
            h.resolve(
              Response(
                requestOptions: o,
                data: {
                  'data': {
                    'tracker_data': {'cry': rows[id] ?? []},
                  },
                },
              ),
            );
          else if (fail)
            h.reject(
              DioException(
                requestOptions: o,
                type: DioExceptionType.connectionError,
              ),
            );
          else {
            rows[id] = (o.data as List)
                .map((r) => Map<String, dynamic>.from(r as Map))
                .toList();
            h.resolve(Response(requestOptions: o, data: {'data': rows[id]}));
          }
        },
      ),
    );
    await tester.pumpWidget(
      MaterialApp(
        home: CryHistoryScreen(api: api, playback: player, historyRange: range),
      ),
    );
    await tester.pumpAndSettle();
    return rows;
  }

  testWidgets('cry history receives report range and can clear it', (
    tester,
  ) async {
    final yesterday = DateUtils.dateOnly(
      DateTime.now().subtract(const Duration(days: 1)),
    );
    await open(
      tester,
      _Playback(),
      range: DateTimeRange(start: yesterday, end: yesterday),
    );
    expect(find.text('Analysis unavailable'), findsOneWidget);
    await tester.tap(find.byTooltip('Show all dates'));
    await tester.pumpAndSettle();
    expect(find.text('Analysis unavailable'), findsNWidgets(2));
  });
  testWidgets(
    'unavailable analysis stays playable with pause/resume and day filters',
    (tester) async {
      final p = _Playback();
      await open(tester, p);
      expect(find.text('Analysis unavailable'), findsNWidgets(2));
      await tester.tap(find.text('Play').first);
      await tester.pumpAndSettle();
      expect(find.text('Pause'), findsOneWidget);
      await tester.tap(find.text('Pause'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Play').first);
      await tester.pumpAndSettle();
      expect(p.toggles, 3);
      await tester.tap(find.text('Today'));
      await tester.pumpAndSettle();
      expect(find.text('Analysis unavailable'), findsOneWidget);
    },
  );
  testWidgets(
    'saved scores and suggestions expand inline without result dialog',
    (tester) async {
      await open(tester, _Playback(), analyzed: true);
      await tester.tap(find.text('Analysis details'));
      await tester.pumpAndSettle();
      expect(find.text('hungry · 70.0%'), findsOneWidget);
      expect(find.text('Saved care suggestion'), findsOneWidget);
      expect(find.byType(AlertDialog), findsNothing);
    },
  );
  testWidgets(
    'delete confirms, stops playback and persists only selected baby',
    (tester) async {
      final p = _Playback();
      final rows = await open(tester, p);
      await tester.tap(find.text('Play').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete').first);
      await tester.pumpAndSettle();
      expect(rows['a'], hasLength(2));
      await tester.tap(find.text('Delete').last);
      await tester.pumpAndSettle();
      expect(rows['a'], hasLength(1));
      expect(p.currentKey, isNull);
      BabyProfileStore.select({'id': 'b', 'name': 'Ben'});
      await tester.pumpAndSettle();
      expect(find.text('Recordings for Ben'), findsOneWidget);
      expect(find.text('Play'), findsNothing);
      expect(rows['a'], hasLength(1));
    },
  );
  testWidgets(
    'failed deletion leaves recording available and shows retry error',
    (tester) async {
      final rows = await open(tester, _Playback(), fail: true);
      await tester.tap(find.text('Delete').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete').last);
      await tester.pumpAndSettle();
      expect(rows['a'], hasLength(2));
      expect(find.text('Play'), findsNWidgets(2));
      expect(find.textContaining('Could not save'), findsOneWidget);
    },
  );
  testWidgets(
    'switching twins stops previous audio; leaving disposes playback',
    (tester) async {
      final p = _Playback();
      await open(tester, p);
      await tester.tap(find.text('Play').first);
      await tester.pumpAndSettle();
      final stops = p.stops;
      BabyProfileStore.select({'id': 'b', 'name': 'Ben'});
      await tester.pumpAndSettle();
      expect(p.stops, greaterThan(stops));
      expect(p.currentKey, isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      expect(p.disposed, true);
    },
  );
}
