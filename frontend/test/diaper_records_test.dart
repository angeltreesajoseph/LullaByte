import 'package:flutter_test/flutter_test.dart';
import 'package:lullabyte/features/diaper/domain/diaper_records.dart';

void main() {
  test('today counts exclude older changes and mixed is counted once', () {
    final day = DateTime(2026, 10, 20);
    final rows = <Map<String, dynamic>>[
      for (final type in ['wet', 'dirty', 'mixed'])
        {'type': type, 'time': day.toIso8601String()},
      {
        'type': 'wet',
        'time': day.subtract(const Duration(days: 1)).toIso8601String(),
      },
    ];
    final today = DiaperRecords.onDay(rows, day);
    expect(today, hasLength(3));
    for (final type in ['wet', 'dirty', 'mixed']) {
      expect(DiaperRecords.count(today, type), 1);
    }
  });
  test('existing time records and UTC records remain readable', () {
    expect(
      DiaperRecords.date({'time': '2026-10-20T08:30:00'}),
      DateTime(2026, 10, 20, 8, 30),
    );
    expect(
      DiaperRecords.date({'occurred_at': '2026-10-20T08:30:00Z'}),
      DateTime.utc(2026, 10, 20, 8, 30).toLocal(),
    );
    expect(DiaperRecords.date({'time': 'invalid'}), isNull);
  });
}
