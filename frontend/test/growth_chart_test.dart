import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lullabyte/features/growth/presentation/widgets/growth_chart.dart';

void main() {
  Future<void> open(
    WidgetTester tester,
    List<Map<String, dynamic>> rows,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(child: GrowthChart(rows: rows)),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('empty and single point states do not imply a trend', (
    tester,
  ) async {
    await open(tester, []);
    expect(find.text('Add a weight measurement to start.'), findsOneWidget);
    await open(tester, [
      {'id': 'a', 'date': '2026-10-20', 'weight': 4},
    ]);
    expect(find.byKey(const ValueKey('growth_point_a')), findsOneWidget);
    expect(
      find.text('One measurement recorded. Add another to see a trend.'),
      findsOneWidget,
    );
  });
  testWidgets(
    'switching units filters missing fields and point taps show exact values',
    (tester) async {
      await open(tester, [
        {'id': 'a', 'date': '2026-10-01', 'weight': 4, 'height': 50},
        {'id': 'b', 'date': '2026-10-20', 'weight': 5, 'head': 35},
      ]);
      await tester.tap(find.byKey(const ValueKey('growth_point_a')));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<Text>(find.byKey(const ValueKey('growth_chart_selection')))
            .data,
        contains('4 kg'),
      );
      await tester.tap(find.byKey(const ValueKey('growth_chart_height')));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('growth_point_a')), findsOneWidget);
      expect(find.byKey(const ValueKey('growth_point_b')), findsNothing);
      expect(
        tester
            .widget<Text>(find.byKey(const ValueKey('growth_chart_selection')))
            .data,
        contains('50 cm'),
      );
      await tester.tap(find.byKey(const ValueKey('growth_chart_head')));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<Text>(find.byKey(const ValueKey('growth_chart_selection')))
            .data,
        contains('35 cm'),
      );
    },
  );
  testWidgets('horizontal distances represent actual elapsed dates', (
    tester,
  ) async {
    await open(tester, [
      for (final i in [0, 1, 10])
        {
          'id': '$i',
          'date': DateTime(2026, 10, 1 + i).toIso8601String(),
          'weight': 4 + i * .1,
        },
    ]);
    final first = tester
        .getCenter(find.byKey(const ValueKey('growth_point_0')))
        .dx;
    final middle = tester
        .getCenter(find.byKey(const ValueKey('growth_point_1')))
        .dx;
    final last = tester
        .getCenter(find.byKey(const ValueKey('growth_point_10')))
        .dx;
    expect((middle - first) / (last - first), closeTo(.1, .001));
  });
}
