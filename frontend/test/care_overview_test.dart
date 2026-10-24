import 'package:flutter_test/flutter_test.dart';
import 'package:lullabyte/features/trackers/domain/care_overview.dart';

void main() {
  test(
    'one inclusive range drives feeding/diaper/cry and excludes reminders and old labels',
    () {
      final day = DateTime(2026, 10, 20);
      final report = CareOverview(
        {
          'name': 'Anna',
          'tracker_data': {
            'feeding': [
              {
                'type': 'bottle',
                'occurred_at': day.toIso8601String(),
                'amount_ml': 50,
              },
              {
                'type': 'solids',
                'occurred_at': day
                    .add(const Duration(hours: 23))
                    .toIso8601String(),
                'food': 'Puree',
              },
              {
                'type': 'bottle',
                'occurred_at': DateTime(2026, 10, 21).toIso8601String(),
                'amount_ml': 90,
              },
              {'record_type': 'reminder', 'reminder_at': day.toIso8601String()},
              {'type': 'bottle', 'time': 'Just now'},
            ],
            'diaper': [
              {'type': 'mixed', 'time': day.toIso8601String()},
            ],
            'cry': [
              {'time': day.toIso8601String(), 'audio_data': 'SENSITIVE AUDIO'},
            ],
          },
        },
        day,
        day,
      );
      expect(report.feeding, hasLength(2));
      expect(report.undated('feeding'), 1);
      expect(report.series('feeding').buckets.single.values['Solids'], 1);
      expect(report.series('bottle').buckets.single.values['Bottle ml'], 50);
      expect(report.series('diaper').buckets.single.values['Mixed'], 1);
      expect(report.cry, hasLength(1));
      expect(report.cry.single.containsKey('audio_data'), false);
    },
  );
  test(
    'cross-midnight completed sleep clipped to selected range; active excluded',
    () {
      final day = DateTime(2026, 10, 20);
      final report = CareOverview(
        {
          'tracker_data': {
            'sleep': [
              {
                'type': 'night',
                'start_at': DateTime(2026, 10, 19, 23).toIso8601String(),
                'end_at': DateTime(2026, 10, 20, 2).toIso8601String(),
              },
              {
                'type': 'nap',
                'record_type': 'active',
                'start_at': day.toIso8601String(),
              },
            ],
          },
        },
        day,
        day,
      );
      expect(report.sleepDuration(), const Duration(hours: 2));
      expect(report.activeSleep, 1);
      expect(report.series('sleep').buckets.single.values['Night'], 120);
    },
  );
  test(
    'missing day differs from zero category in a recorded bucket; twins stay separate',
    () {
      final report = CareOverview(
        {
          'tracker_data': {
            'diaper': [
              {'type': 'wet', 'time': '2026-10-20'},
            ],
          },
        },
        DateTime(2026, 10, 19),
        DateTime(2026, 10, 20),
      );
      final buckets = report.series('diaper').buckets;
      expect(buckets.first.recorded, false);
      expect(buckets.last.recorded, true);
      expect(buckets.last.values['Mixed'], 0);
      expect(
        CareOverview(
          {},
          DateTime(2026, 10, 20),
          DateTime(2026, 10, 20),
        ).series('diaper').empty,
        true,
      );
    },
  );
  test(
    'snapshot is unaffected by later data edits; custom range bins remain bounded',
    () {
      final profile = <String, dynamic>{
        'name': 'Anna',
        'tracker_data': {
          'growth': [
            {'date': '2026-01-01', 'weight': 4},
          ],
        },
      };
      final report = CareOverview(
        profile,
        DateTime(2026, 1, 1),
        DateTime(2026, 12, 31),
      );
      ((profile['tracker_data'] as Map)['growth'] as List).clear();
      profile['name'] = 'Ben';
      expect(report.name, 'Anna');
      expect(report.growth, hasLength(1));
      expect(report.series('feeding').buckets, hasLength(12));
    },
  );
  test(
    'vaccination received/planned dates are filtered and achievements labelled all-time',
    () {
      final report = CareOverview(
        {
          'tracker_data': {
            'vaccinations': [
              {
                'id': 'one',
                'name': 'Custom received',
                'custom': true,
                'done': true,
                'due_date': '2026-10-01',
                'received_date': '2026-10-20',
              },
              {
                'id': 'two',
                'name': 'Custom planned',
                'custom': true,
                'done': false,
                'due_date': '2026-10-20',
              },
              {
                'id': 'three',
                'name': 'Later',
                'custom': true,
                'done': false,
                'due_date': '2026-10-25',
              },
            ],
            'milestones': [
              {'name': 'A saved achievement', 'achieved': true},
            ],
          },
        },
        DateTime(2026, 10, 20),
        DateTime(2026, 10, 20),
      );
      expect(report.received, hasLength(1));
      expect(report.planned, hasLength(1));
      expect(report.upcoming, hasLength(1));
      expect(report.milestoneScope, contains('all time'));
    },
  );
}
