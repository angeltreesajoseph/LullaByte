import 'package:flutter_test/flutter_test.dart';
import 'package:lullabyte/features/feeding/domain/feeding_records.dart';

void main() {
  test(
    'daily totals exclude other days, reminders, solids and legacy rows',
    () {
      final day = DateTime(2026, 10, 20);
      final rows = <Map<String, dynamic>>[
        {
          'type': 'bottle',
          'occurred_at': day.toIso8601String(),
          'amount_ml': 90.5,
        },
        {
          'type': 'breastfeed',
          'occurred_at': day.toIso8601String(),
          'duration_min': 12,
        },
        {
          'type': 'solids',
          'occurred_at': day.toIso8601String(),
          'food': 'Puree',
        },
        {
          'type': 'bottle',
          'occurred_at': day
              .subtract(const Duration(days: 1))
              .toIso8601String(),
          'amount_ml': 100,
        },
        {'type': 'bottle', 'amount': '120 ml', 'time': 'Just now'},
        {'record_type': 'reminder', 'reminder_at': day.toIso8601String()},
      ];
      final today = FeedingRecords.onDay(rows, day);
      expect(today.length, 3);
      expect(FeedingRecords.bottleMl(today), 90.5);
      expect(FeedingRecords.breastMinutes(today), 12);
      expect(
        FeedingRecords.dashboard({
          'tracker_data': {'feeding': rows},
        }, day),
        '3 feeds today',
      );
    },
  );
  test('twins have independent summaries and empty data is not demo data', () {
    final day = DateTime(2026, 10, 20);
    final baby = {
      'tracker_data': {
        'feeding': [
          {
            'type': 'bottle',
            'occurred_at': day.toIso8601String(),
            'amount_ml': 30,
          },
        ],
      },
    };
    expect(FeedingRecords.dashboard(baby, day), '1 feeds today');
    expect(FeedingRecords.dashboard({}, day), 'No feeds logged today');
  });
}
