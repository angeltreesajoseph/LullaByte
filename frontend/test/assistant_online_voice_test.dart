import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lullabyte/features/ai_assistant/application/assistant_providers.dart';
import 'package:lullabyte/features/ai_assistant/application/chat_controller.dart';
import 'package:lullabyte/features/ai_assistant/data/repositories/gemini_response_service.dart';
import 'package:lullabyte/features/ai_assistant/domain/repositories/ai_response_service.dart';
import 'package:lullabyte/features/ai_assistant/presentation/screens/ai_assistant_screen.dart';
import 'package:lullabyte/features/baby_management/application/baby_profile_store.dart';

class FakeGemini implements AiResponseService {
  final histories = <List<Map<String, String>>>[];
  @override
  Future<String> getResponse(
    String question, {
    List<Map<String, String>> history = const [],
  }) async {
    histories.add(history);
    return 'Online answer';
  }
}

void main() {
  testWidgets('named twins are answered locally without a Gemini request', (
    tester,
  ) async {
    GoogleFonts.config.allowRuntimeFetching = false;
    final babies = [
      {
        'id': 'one',
        'name': 'J Mol',
        'birth_date': '2026-01-01',
        'tracker_data': <String, dynamic>{},
      },
      {
        'id': 'two',
        'name': 'J Mon',
        'birth_date': '2026-01-02',
        'tracker_data': <String, dynamic>{},
      },
    ];
    BabyProfileStore.babies = babies;
    BabyProfileStore.select(babies.first);
    addTearDown(() => BabyProfileStore.babies = []);
    final service = FakeGemini();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [aiResponseServiceProvider.overrideWithValue(service)],
        child: const MaterialApp(home: AiAssistantScreen()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.enterText(
      find.byType(TextField),
      'Can you give details about jmol and jmon?',
    );
    await tester.tap(find.byTooltip('Send'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(service.histories, isEmpty);
    expect(find.textContaining('J Mol — saved profile'), findsOneWidget);
    expect(find.textContaining('J Mon — saved profile'), findsOneWidget);
    expect(find.textContaining('Saved records ·'), findsOneWidget);
    expect(find.text('Use Gemini online?'), findsNothing);
    await tester.pumpWidget(const SizedBox());
  });
  setUp(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    BabyProfileStore.select({
      'id': 'one',
      'name': 'Anna',
      'tracker_data': {'private': 'PRIVATE_RECORD'},
      'photo_data': 'PRIVATE_PHOTO',
    });
  });
  tearDown(() {
    BabyProfileStore.id = null;
    BabyProfileStore.data = {};
  });
  test(
    'Gemini transport sends selected baby path and no automatic tracker/photo context',
    () async {
      final requests = <RequestOptions>[];
      final api = Dio()
        ..interceptors.add(
          InterceptorsWrapper(
            onRequest: (o, h) {
              requests.add(o);
              h.resolve(
                Response(
                  requestOptions: o,
                  data: {
                    'data': {'answer': 'Hello'},
                  },
                ),
              );
            },
          ),
        );
      expect(
        await GeminiResponseService(api: api).getResponse('Question'),
        'Hello',
      );
      expect(requests.single.path, '/babies/one/assistant');
      expect(requests.single.data, {
        'question': 'Question',
        'history': [],
        'consent': true,
      });
      expect(requests.single.data.toString(), isNot(contains('PRIVATE')));
    },
  );
  test(
    'online history excludes offline tracker answers and stays baby scoped',
    () async {
      final service = FakeGemini();
      final container = ProviderContainer(
        overrides: [aiResponseServiceProvider.overrideWithValue(service)],
      );
      addTearDown(container.dispose);
      final controller = container.read(chatControllerProvider.notifier);
      await controller.sendMessage('Profile details', isOnline: false);
      await controller.sendMessage('Question', isOnline: true);
      expect(service.histories.first, isEmpty);
      await controller.sendMessage('Follow-up', isOnline: true);
      expect(service.histories.last, hasLength(2));
      expect(service.histories.last.last['text'], 'Online answer');
      BabyProfileStore.select({'id': 'two', 'name': 'Ben', 'tracker_data': {}});
      await controller.sendMessage('Question', isOnline: true);
      expect(service.histories.last, isEmpty);
    },
  );
  testWidgets(
    'voice inserts editable text without sending; reply read aloud can stop',
    (tester) async {
      tester.view.physicalSize = const Size(430, 1100);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      const channel = MethodChannel('lullabyte/assistant_voice');
      final spoken = Completer<void>();
      final calls = <MethodCall>[];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            calls.add(call);
            if (call.method == 'dictate') return 'Feeding records';
            if (call.method == 'speak') await spoken.future;
            if (call.method == 'stop' &&
                calls.any((c) => c.method == 'speak') &&
                !spoken.isCompleted)
              spoken.complete();
            return null;
          });
      addTearDown(
        () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, null),
      );
      final container = ProviderContainer();
      addTearDown(container.dispose);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: AiAssistantScreen()),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await tester.tap(find.byTooltip('Speak message'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await tester.tap(find.text('Continue'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        'Feeding records',
      );
      expect(container.read(chatControllerProvider).messages, hasLength(1));
      await tester.tap(find.byTooltip('Send'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await tester.pump();
      await tester.tap(find.byTooltip('Read aloud'));
      await tester.pump();
      expect(find.byTooltip('Stop reading'), findsOneWidget);
      await tester.tap(find.byTooltip('Stop reading'));
      await tester.pump();
      expect(calls.any((c) => c.method == 'speak'), true);
      expect(find.byTooltip('Read aloud'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    },
  );
  testWidgets(
    'general questions send without popup with visible Gemini disclosure',
    (tester) async {
      tester.view.physicalSize = const Size(430, 1100);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final service = FakeGemini();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [aiResponseServiceProvider.overrideWithValue(service)],
          child: const MaterialApp(home: AiAssistantScreen()),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await tester.enterText(
        find.byType(TextField),
        'Explain newborn vaccines',
      );
      await tester.tap(find.byTooltip('Send'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('Use Gemini online?'), findsNothing);
      expect(
        find.textContaining('recent online chat go to Google Gemini'),
        findsOneWidget,
      );
      expect(service.histories.length, 1);
      expect(find.text('Online answer'), findsOneWidget);
      expect(find.byTooltip('Assistant mode'), findsNothing);
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        '',
      );
      await tester.pumpWidget(const SizedBox());
    },
  );
}
