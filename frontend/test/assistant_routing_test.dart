import 'package:flutter_test/flutter_test.dart';
import 'package:lullabyte/features/ai_assistant/domain/usecases/assistant_routing.dart';
import 'package:lullabyte/features/baby_management/application/baby_profile_store.dart';

void main() {
  setUp(() {
    BabyProfileStore.name = 'Anna';
    BabyProfileStore.babies = [
      {'id': 'one', 'name': 'J Mol'},
      {'id': 'two', 'name': 'J Mon'},
    ];
  });
  tearDown(() {
    BabyProfileStore.name = 'Your baby';
    BabyProfileStore.babies = [];
  });
  test('personal record lookups stay local', () {
    for (final q in [
      'Feeding records',
      "What is my baby's blood group?",
      'Anna weight',
      'Next vaccine',
      'Latest sleep record',
      'Can you give details about J Mol and J Mon?',
      'Can you give details about jmol and jmon?',
      'Dont you have details about the baby profiles of this app',
      'Show both babies details',
      'Internal baby data',
    ]) {
      expect(AssistantRouting.usesRecords(q), true, reason: q);
    }
  });
  test(
    'general explanations do not get mistaken for personal record lookups',
    () {
      for (final q in [
        'Explain vaccines for newborns and their doses',
        'Why is my baby crying?',
        'Is my baby sleeping enough?',
        'How can caregivers coordinate care?',
      ]) {
        expect(AssistantRouting.usesRecords(q), false, reason: q);
      }
    },
  );
}
