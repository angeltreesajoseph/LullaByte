import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:lullabyte/core/router/app_router.dart';
import 'package:lullabyte/main.dart';

void main() {
  testWidgets('system Back returns root features home and pops pushed pages',
      (tester) async {
    final router = GoRouter(initialLocation: '/feeding', routes: [
      for (final path in ['/dashboard', '/feeding', '/history', '/chat'])
        GoRoute(path: path, builder: (_, _) => Scaffold(body: Text(path))),
    ]);
    addTearDown(router.dispose);
    await tester.pumpWidget(ProviderScope(
      overrides: [goRouterProvider.overrideWithValue(router)],
      child: const LullaByteApp(),
    ));
    await tester.pumpAndSettle();
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('/dashboard'), findsOneWidget);

    router.push('/feeding');
    await tester.pumpAndSettle();
    router.push('/history');
    await tester.pumpAndSettle();
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('/feeding'), findsOneWidget);

    await showDialogTest(tester);
    expect(find.text('/feeding'), findsOneWidget);
    router.go('/chat');
    await tester.pumpAndSettle();
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('/dashboard'), findsOneWidget);
  });
}

Future<void> showDialogTest(WidgetTester tester) async {
  showDialog<void>(
    context: tester.element(find.text('/feeding')),
    builder: (_) => const AlertDialog(content: Text('dialog')),
  );
  await tester.pumpAndSettle();
  await tester.binding.handlePopRoute();
  await tester.pumpAndSettle();
  expect(find.text('dialog'), findsNothing);
}
