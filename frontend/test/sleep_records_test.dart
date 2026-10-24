import 'package:flutter_test/flutter_test.dart';
import 'package:lullabyte/features/sleep/domain/sleep_records.dart';

void main() {
  Map<String, dynamic> session(
    String id,
    DateTime start,
    DateTime end, {
    String type = 'night',
  }) => {
    'id': id,
    'type': type,
    'start_at': start.toUtc().toIso8601String(),
    'end_at': end.toUtc().toIso8601String(),
  };
  test('cross-midnight sleep is split by local date, not counted twice', () {
    final row = session(
      'a',
      DateTime(2026, 10, 19, 23),
      DateTime(2026, 10, 20, 2),
    );
    expect(
      SleepRecords.onDay([row], DateTime(2026, 10, 19)),
      const Duration(hours: 1),
    );
    expect(
      SleepRecords.onDay([row], DateTime(2026, 10, 20)),
      const Duration(hours: 2),
    );
    expect(SleepRecords.touchesDay(row, DateTime(2026, 10, 19)), true);
    expect(SleepRecords.touchesDay(row, DateTime(2026, 10, 20)), true);
    expect(SleepRecords.touchesDay(row, DateTime(2026, 10, 21)), false);
  });
  test('totals exclude active timers, legacy labels and other days', () {
    final day = DateTime(2026, 10, 20);
    final rows = <Map<String, dynamic>>[
      session(
        'a',
        day.add(const Duration(hours: 1)),
        day.add(const Duration(hours: 3)),
      ),
      session(
        'b',
        day.add(const Duration(hours: 5)),
        day.add(const Duration(hours: 6)),
        type: 'nap',
      ),
      {
        'record_type': 'active',
        'start_at': day.toIso8601String(),
        'type': 'nap',
      },
      {'duration': '2h 30m', 'time': 'Yesterday', 'type': 'nap'},
    ];
    expect(SleepRecords.onDay(rows, day), const Duration(hours: 3));
    expect(
      SleepRecords.onDay(rows, day, type: 'nap'),
      const Duration(hours: 1),
    );
    expect(
      SleepRecords.onDay(rows, day, type: 'night'),
      const Duration(hours: 2),
    );
  });
  test(
    'validation rejects reversed, future, before birth and overlapping sessions',
    () {
      final now = DateTime(2026, 10, 20, 12);
      final existing = session(
        'a',
        DateTime(2026, 10, 20, 8),
        DateTime(2026, 10, 20, 9),
      );
      expect(
        SleepRecords.validate(
          session('b', now, now.subtract(const Duration(hours: 1))),
          [],
          now,
        ),
        contains('after start'),
      );
      expect(
        SleepRecords.validate(
          session('b', now, now.add(const Duration(hours: 1))),
          [],
          now,
        ),
        contains('future'),
      );
      expect(
        SleepRecords.validate(existing, [], now, birth: DateTime(2026, 10, 21)),
        contains('before birth'),
      );
      final overlap = session(
        'b',
        DateTime(2026, 10, 20, 8, 30),
        DateTime(2026, 10, 20, 10),
      );
      expect(
        SleepRecords.validate(overlap, [existing], now),
        contains('overlaps'),
      );
      expect(SleepRecords.validate(existing, [existing], now), isNull);
      expect(
        SleepRecords.validate(
          session('b', DateTime(2026, 10, 20, 9), DateTime(2026, 10, 20, 10)),
          [existing],
          now,
        ),
        isNull,
      );
    },
  );
  test(
    'active timer blocks overlapping manual records; summaries stay per baby',
    () {
      final now = DateTime(2026, 10, 20, 12);
      final active = {
        'id': 'a',
        'type': 'nap',
        'record_type': 'active',
        'start_at': DateTime(2026, 10, 20, 11).toIso8601String(),
      };
      expect(
        SleepRecords.validate(
          session('b', DateTime(2026, 10, 20, 11, 30), now),
          [active],
          now,
        ),
        contains('overlaps'),
      );
      expect(
        SleepRecords.dashboard({
          'tracker_data': {
            'sleep': [active],
          },
        }, now),
        'Sleep timer running',
      );
      expect(SleepRecords.dashboard({}, now), 'No sleep logged today');
    },
  );
}
