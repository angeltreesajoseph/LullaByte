import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lullabyte/features/notifications/presentation/screens/notification_preferences_screen.dart';

void main() {
  const notifications = MethodChannel(
    'dexterous.com/flutter/local_notifications',
  );
  const settings = MethodChannel('lullabyte/notification_settings');
  final calls = <MethodCall>[];
  setUp(() {
    AndroidFlutterLocalNotificationsPlugin.registerWith();
    calls.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(notifications, (call) async {
          calls.add(call);
          if (call.method == 'areNotificationsEnabled' ||
              call.method == 'requestNotificationsPermission')
            return true;
          if (call.method == 'getNotificationChannels') return <dynamic>[];
          return null;
        });
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(settings, (call) async {
          calls.add(call);
          return null;
        });
  });
  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(notifications, null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(settings, null);
  });
  testWidgets(
    'preferences expose real phone controls and category test alerts',
    (tester) async {
      tester.view.physicalSize = const Size(430, 1400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        const MaterialApp(home: NotificationPreferencesScreen()),
      );
      await tester.pumpAndSettle();
      expect(find.text('Shared care updates'), findsOneWidget);
      expect(find.text('Feeding reminders'), findsOneWidget);
      expect(find.text('Vaccination reminders'), findsOneWidget);
      expect(
        calls.where((c) => c.method == 'createNotificationChannel'),
        hasLength(4),
      );
      await tester.tap(find.text('Sound & vibration').first);
      await tester.pumpAndSettle();
      expect((calls.last.arguments as Map)['channel'], 'shared_care');
      await tester.tap(find.text('Test alert').first);
      await tester.pumpAndSettle();
      final shown = calls.singleWhere((c) => c.method == 'show');
      expect((shown.arguments as Map)['title'], contains('Test notification'));
      expect(tester.takeException(), isNull);
    },
  );
}
