import 'package:flutter_test/flutter_test.dart';
import 'package:lullabyte/features/growth/domain/growth_records.dart';

void main() {
  test('latest value is per metric and sorted by measurement date', () {
    final rows = <Map<String, dynamic>>[
      {'id': 'new', 'date': '2026-10-20', 'weight': 6, 'height': null},
      {'id': 'old', 'date': '2026-10-01', 'weight': 5, 'height': 60},
      {'id': 'zero', 'date': '2026-10-21', 'weight': 0, 'head': 0},
    ];
    expect(GrowthRecords.latest(rows, GrowthMetric.weight)!['id'], 'new');
    expect(GrowthRecords.latest(rows, GrowthMetric.height)!['id'], 'old');
    expect(GrowthRecords.latest(rows, GrowthMetric.head), isNull);
    expect(
      GrowthRecords.points(rows, GrowthMetric.weight).map((r) => r['id']),
      ['old', 'new'],
    );
  });
  test('missing, zero and invalid legacy values never become chart points', () {
    for (final value in [null, 0, -1, double.nan, double.infinity, 'invalid']) {
      expect(
        GrowthRecords.value({'weight': value}, GrowthMetric.weight),
        isNull,
      );
    }
    expect(GrowthRecords.value({'weight': '3.25'}, GrowthMetric.weight), 3.25);
  });
  test('dashboard distinguishes registration from dated growth and twins', () {
    expect(
      GrowthRecords.dashboardWeight({'birth_weight_kg': 3.2}),
      '3.2 kg (registration)',
    );
    expect(
      GrowthRecords.dashboardWeight({
        'birth_weight_kg': 3.2,
        'tracker_data': {
          'growth': [
            {'date': '2026-10-20', 'weight': 6},
          ],
        },
      }),
      '6 kg (growth)',
    );
    expect(GrowthRecords.dashboardWeight({}), 'Not recorded');
  });
}
