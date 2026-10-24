import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lullabyte/core/di/providers.dart';
import 'package:lullabyte/core/constants/storage_keys.dart';
import 'package:lullabyte/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('LullaByteApp boots and shows the Splash screen', (tester) async {
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
    SharedPreferences.setMockInitialValues(const {StorageKeys.themeMode: 'dark'});
    final sharedPreferences = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(sharedPreferences),
        ],
        child: const LullaByteApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('LullaByte'), findsOneWidget);
    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.themeMode, ThemeMode.light);
    expect(Theme.of(tester.element(find.byType(Scaffold).first)).brightness,
        Brightness.light);
  });
}
