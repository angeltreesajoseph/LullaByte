import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lullabyte/features/cry_analyzer/application/cry_completion_feedback.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('dexterous.com/flutter/local_notifications');
  final calls = <MethodCall>[];
  bool allowed = true;
  setUp(() {
    allowed = true;
    AndroidFlutterLocalNotificationsPlugin.registerWith();
    calls.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          calls.add(call);
          if (call.method == 'areNotificationsEnabled' ||
              call.method == 'requestNotificationsPermission')
            return allowed;
          return null;
        });
  });
  tearDown(
    () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null),
  );
  test(
    'visible result requests a silent notification with a 500ms vibration',
    () async {
      await cryCompletionFeedback(visible: true);
      final shown =
          calls.singleWhere((c) => c.method == 'show').arguments as Map;
      expect(shown['id'], 740200);
      expect(shown['body'], 'Analysis ready. Open the app.');
      final android = shown['platformSpecifics'] as Map;
      expect(android['channelId'], 'cry_results');
      expect(android['enableVibration'], true);
      expect(android['vibrationPattern'], [0, 500]);
      expect(android['playSound'], false);
      expect(android['styleInformation'], isNotNull);
    },
  );
  test('no vibration for an offscreen result', () async {
    await cryCompletionFeedback(visible: false);
    expect(calls, isEmpty);
  });
  test('denied permission does not post or fail the saved analysis', () async {
    allowed = false;
    await cryCompletionFeedback(visible: true);
    expect(calls.where((c) => c.method == 'show'), isEmpty);
  });
  test('plugin failures do not fail analysis completion', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (_) async {
          throw PlatformException(code: 'unsupported');
        });
    await expectLater(cryCompletionFeedback(visible: true), completes);
  });
}
