import 'dart:typed_data';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// A notification-channel pulse means "result ready", never a medical alarm.
/// The phone's notification preferences remain authoritative.
Future<void> cryCompletionFeedback({required bool visible}) async {
  if (!visible) return;
  try {
    final plugin = FlutterLocalNotificationsPlugin();
    final android = plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android != null &&
        await android.areNotificationsEnabled() != true &&
        await android.requestNotificationsPermission() != true)
      return;
    await plugin.show(
      id: 740200,
      title: 'LullaByte · Analysis ready',
      body: 'Analysis ready. Open the app.',
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          'cry_results',
          'Cry analysis ready',
          channelDescription: 'A short vibration when a new analysis is ready',
          importance: Importance.high,
          priority: Priority.high,
          playSound: false,
          enableVibration: true,
          vibrationPattern: Int64List.fromList([0, 500]),
          onlyAlertOnce: false,
          styleInformation: const BigTextStyleInformation(
            'Your recording has been analyzed. Open LullaByte to view the result and care suggestions.',
          ),
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentSound: false,
        ),
      ),
    );
  } catch (_) {
    // Disabled notifications must not turn a saved result into an error.
  }
}
