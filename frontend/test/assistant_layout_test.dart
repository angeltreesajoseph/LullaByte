import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lullabyte/features/ai_assistant/presentation/screens/ai_assistant_screen.dart';
import 'package:lullabyte/features/baby_management/application/baby_profile_store.dart';

void main() {
  testWidgets('small screen leaves space for messages with keyboard open', (
    tester,
  ) async {
    GoogleFonts.config.allowRuntimeFetching = false;
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    tester.view.viewInsets = const FakeViewPadding(bottom: 280);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetViewInsets);
    BabyProfileStore.select({'id': 'one', 'name': 'Anna', 'tracker_data': {}});
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: AiAssistantScreen())),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Saved records for Anna'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    BabyProfileStore.id = null;
    BabyProfileStore.data = {};
  });
  testWidgets(
    'simple records helper has no fake AI/microphone and hides starter prompts after sending',
    (tester) async {
      GoogleFonts.config.allowRuntimeFetching = false;
      tester.view.physicalSize = const Size(430, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      BabyProfileStore.select({
        'id': 'one',
        'name': 'Anna',
        'tracker_data': {},
      });
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: AiAssistantScreen())),
      );
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('Online AI'), findsNothing);
      expect(find.byIcon(Icons.mic_none_rounded), findsOneWidget);
      expect(find.byTooltip('Assistant mode'), findsNothing);
      await tester.tap(find.text('Feeding records'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await tester.pump();
      expect(
        find.textContaining('No feeding records are available for Anna'),
        findsOneWidget,
      );
      expect(
        tester.getTopLeft(find.text('Feeding records')).dx,
        greaterThan(
          tester
              .getTopLeft(
                find.textContaining(
                  'No feeding records are available for Anna',
                ),
              )
              .dx,
        ),
      );
      expect(find.text('Sleep records'), findsNothing);
      await tester.tap(find.byTooltip('Clear conversation'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await tester.tap(find.text('Clear'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('Sleep records'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      BabyProfileStore.id = null;
      BabyProfileStore.data = {};
    },
  );
}
