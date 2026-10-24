import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lullabyte/features/ai_assistant/application/assistant_providers.dart';
import 'package:lullabyte/features/ai_assistant/application/chat_controller.dart';
import 'package:lullabyte/features/ai_assistant/domain/repositories/ai_response_service.dart';
import 'package:lullabyte/features/ai_assistant/domain/usecases/local_response_engine.dart';
import 'package:lullabyte/features/baby_management/application/baby_profile_store.dart';

Map<String, dynamic> profile(String id) => {
  'id': id,
  'name': id,
  'tracker_data': {
    'feeding': [
      {
        'record_type': 'reminder',
        'occurred_at': '2030-01-01',
        'amount_ml': 9999,
      },
      {'type': 'bottle', 'occurred_at': '2026-01-01', 'amount_ml': 10},
      {'type': 'bottle', 'occurred_at': '2026-02-01', 'amount_ml': 80},
    ],
    'growth': [
      {'date': '2026-01-01', 'weight': 4, 'height': 52, 'head': 35},
    ],
    'vaccinations': [
      {'name': 'Saved dose', 'done': false, 'due_date': '2026-11-01'},
    ],
    'cry': [
      {'time': '2026-01-01', 'audio_data': 'PRIVATE_AUDIO'},
    ],
  },
};

class DelayedService implements AiResponseService {
  final result = Completer<String>();
  @override
  Future<String> getResponse(
    String question, {
    List<Map<String, String>> history = const [],
  }) => result.future;
}

void main() {
  setUp(() => BabyProfileStore.select(profile('Anna')));
  tearDown(() {
    BabyProfileStore.id = null;
    BabyProfileStore.data = {};
    BabyProfileStore.babies = [];
  });
  test('record summaries exclude reminders and select latest by date', () {
    const engine = LocalResponseEngine();
    final reply = engine.respond('Feeding records');
    expect(reply, contains('2 saved feeding records'));
    expect(reply, contains('80 ml'));
    expect(reply, isNot(contains('9999')));
    expect(reply, isNot(contains('occurred_at')));
    expect(engine.respond('Growth records'), contains('4 kg'));
    expect(engine.respond('Next saved vaccination'), contains('Saved dose'));
    expect(engine.respond('Cry records'), isNot(contains('PRIVATE_AUDIO')));
    BabyProfileStore.select({'id': 'Ben', 'name': 'Ben', 'tracker_data': {}});
    expect(
      engine.respond('Sleep records'),
      contains('No sleep records are available for Ben'),
    );
    expect(
      engine.respond('unknown'),
      isNot(contains("don't have saved sleep")),
    );
  });
  test(
    'profile questions summarize both named babies without changing selection',
    () {
      BabyProfileStore.babies = [
        {...profile('J Mol'), 'id': 'one', 'birth_date': '2026-01-01'},
        {...profile('J Mon'), 'id': 'two', 'birth_date': '2026-01-02'},
      ];
      final original = BabyProfileStore.id;
      final reply = const LocalResponseEngine().respond(
        'Can you give details about J Mol and J Mon?',
      );
      expect(reply, contains('J Mol — saved profile'));
      expect(reply, contains('J Mon — saved profile'));
      expect(reply, contains('2026-01-01'));
      expect(reply, contains('2026-01-02'));
      expect(reply, isNot(contains('PRIVATE_AUDIO')));
      expect(BabyProfileStore.id, original);
    },
  );
  test(
    'conversation follows twins, restores session history and clears only selected baby',
    () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final controller = container.read(chatControllerProvider.notifier);
      await controller.sendMessage('Feeding records', isOnline: false);
      final anna = container
          .read(chatControllerProvider)
          .messages
          .map((m) => m.text)
          .toList();
      BabyProfileStore.select(profile('Ben'));
      expect(container.read(chatControllerProvider).messages, hasLength(1));
      await controller.sendMessage('Growth records', isOnline: false);
      controller.clearConversation();
      expect(container.read(chatControllerProvider).messages, hasLength(1));
      BabyProfileStore.select(profile('Anna'));
      expect(
        container
            .read(chatControllerProvider)
            .messages
            .map((m) => m.text)
            .toList(),
        anna,
      );
      final ids = container
          .read(chatControllerProvider)
          .messages
          .map((m) => m.id)
          .toList();
      expect(ids.toSet().length, ids.length);
    },
  );
  test('late answer is ignored after switching away and back', () async {
    final service = DelayedService();
    final container = ProviderContainer(
      overrides: [aiResponseServiceProvider.overrideWithValue(service)],
    );
    addTearDown(container.dispose);
    final task = container
        .read(chatControllerProvider.notifier)
        .sendMessage('Question', isOnline: true);
    BabyProfileStore.select(profile('Ben'));
    BabyProfileStore.select(profile('Anna'));
    service.result.complete('Old answer');
    await task;
    expect(
      container
          .read(chatControllerProvider)
          .messages
          .any((m) => m.text == 'Old answer'),
      false,
    );
    expect(container.read(chatControllerProvider).isTyping, false);
  });
  test(
    'failed response stops typing; logout clears session conversations',
    () async {
      final service = DelayedService();
      final container = ProviderContainer(
        overrides: [aiResponseServiceProvider.overrideWithValue(service)],
      );
      addTearDown(container.dispose);
      final task = container
          .read(chatControllerProvider.notifier)
          .sendMessage('Question', isOnline: true);
      service.result.completeError(StateError('unavailable'));
      await task;
      expect(container.read(chatControllerProvider).isTyping, false);
      expect(
        container.read(chatControllerProvider).messages.last.text,
        contains('Please try again'),
      );
      BabyProfileStore.select({});
      BabyProfileStore.select(profile('Anna'));
      expect(container.read(chatControllerProvider).messages, hasLength(1));
    },
  );
}
