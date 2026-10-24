import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lullabyte/features/cry_analyzer/presentation/widgets/cry_analysis_result.dart';

void main() {
  testWidgets('scores and comfort checks are visible inline', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: CryAnalysisResult(
              entry: {
                'mode': 'model',
                'label': 'hungry',
                'scores': {
                  'hungry': 79,
                  'tired': 6,
                  'discomfort': 8,
                  'noise': 5,
                  'belly_pain': 2,
                },
                'tip': 'Check feeding cues.',
                'alternatives': [],
              },
            ),
          ),
        ),
      ),
    );
    expect(find.text('Possible sound match: hungry'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsNWidgets(5));
    expect(find.text('hungry · 79.0%'), findsOneWidget);
    expect(find.text('Check feeding cues.'), findsOneWidget);
    expect(find.byType(AlertDialog), findsNothing);
  });
  testWidgets('known recording is not shown as 100 percent model confidence', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: CryAnalysisResult(
              entry: {
                'mode': 'known_dataset',
                'label': 'tired',
                'scores': null,
              },
            ),
          ),
        ),
      ),
    );
    expect(find.text('Known dataset recording: tired'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsNothing);
    expect(find.textContaining('not 100% AI confidence'), findsOneWidget);
  });
  test('uncertain scores do not produce a definite reason', () {
    expect(
      cryResultTitle({'mode': 'model', 'label': 'hungry', 'uncertain': true}),
      'No clear sound-pattern match',
    );
  });
}
