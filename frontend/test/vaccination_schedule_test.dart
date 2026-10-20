import 'package:flutter_test/flutter_test.dart';
import 'package:lullabyte/features/vaccination/domain/vaccination_schedule.dart';
import 'package:lullabyte/features/vaccination/application/vaccination_reminders.dart';

void main() {
  test(
    'government infant schedule has stable ids and correct week offsets',
    () {
      final dob = DateTime(2024, 1, 31);
      final entries = suggestedVaccinations(dob);
      expect(entries.map((e) => e['id']).toSet().length, entries.length);
      expect(
        DateTime.parse(
          entries.firstWhere((e) => e['id'] == 'opv_1')['due_date'],
        ),
        dob.add(const Duration(days: 42)),
      );
      expect(
        DateTime.parse(
          entries.firstWhere((e) => e['id'] == 'fipv_3')['due_date'],
        ),
        DateTime(2024, 10, 31),
      );
      expect(entries.where((e) => e['excluded'] == true).map((e) => e['id']), [
        'je_1',
        'je_2',
      ]);
      expect(
        entries.where((e) => e['name'].toString().contains('Vitamin')),
        isEmpty,
      );
    },
  );
  test('month arithmetic clamps month ends and leap days', () {
    expect(addCalendarMonths(DateTime(2024, 1, 31), 1), DateTime(2024, 2, 29));
    expect(addCalendarMonths(DateTime(2024, 2, 29), 12), DateTime(2025, 2, 28));
  });
  test(
    'completion persists while unmodified suggested dates follow corrected DOB',
    () {
      final saved = suggestedVaccinations(DateTime(2024, 1, 1));
      saved[0] = {
        ...saved[0],
        'done': true,
        'received_date': '2024-01-01T00:00:00',
      };
      final changed = mergeVaccinations(DateTime(2024, 1, 2), saved);
      final bcg = changed.firstWhere((e) => e['id'] == 'bcg');
      expect(bcg['done'], true);
      expect(DateTime.parse(bcg['due_date']), DateTime(2024, 1, 2));
      expect(bcg['received_date'], '2024-01-01T00:00:00');
    },
  );
  test('manual planned dates and custom doses survive recalculation', () {
    final saved = suggestedVaccinations(DateTime(2024, 1, 1));
    saved[0] = {
      ...saved[0],
      'due_override': true,
      'due_date': '2024-02-01T00:00:00',
    };
    saved.add({
      'id': 'custom_1',
      'custom': true,
      'name': 'Custom dose',
      'due_date': '2024-03-01T00:00:00',
    });
    final merged = mergeVaccinations(DateTime(2024, 1, 2), saved);
    expect(
      merged.firstWhere((e) => e['id'] == 'bcg')['due_date'],
      '2024-02-01T00:00:00',
    );
    expect(merged.where((e) => e['id'] == 'custom_1').length, 1);
    expect(mergeVaccinations(null, []), isEmpty);
  });
  test('reminder ids are deterministic and isolated per user and twin', () {
    final first = VaccinationReminders.id('owner', 'baby1', 'mr_1');
    expect(first, VaccinationReminders.id('owner', 'baby1', 'mr_1'));
    expect(first, isNot(VaccinationReminders.id('owner', 'baby2', 'mr_1')));
    expect(first, isNot(VaccinationReminders.id('other', 'baby1', 'mr_1')));
  });
}
