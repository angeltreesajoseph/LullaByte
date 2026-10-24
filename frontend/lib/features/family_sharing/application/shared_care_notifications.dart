import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import '../../notifications/application/notification_navigation.dart';
import '../../notifications/data/shared_alert_inbox.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'shared_care_connection.dart';

class SharedCareNotifications {
  /// This phone/account preference plus the actual OS permission.
  static Future<bool> isEnabled() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null ||
        _stopping ||
        (await SharedPreferences.getInstance()).getBool('shared_push_$uid') !=
            true)
      return false;
    final settings = await FirebaseMessaging.instance.getNotificationSettings();
    return settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
  }

  static StreamSubscription<String>? _tokens;
  static StreamSubscription<User?>? _users;
  static StreamSubscription<RemoteMessage>? _messages;
  static StreamSubscription<RemoteMessage>? _opened;
  static String? _token;
  static bool _stopping = false;
  static Future<void> start() async {
    _opened ??= FirebaseMessaging.onMessageOpenedApp.listen(
      (message) => NotificationNavigation.shared(message.data),
    );
    final initial = await FirebaseMessaging.instance.getInitialMessage();
    if (initial != null) NotificationNavigation.shared(initial.data);
    _users ??= FirebaseAuth.instance.authStateChanges().listen((user) async {
      if (user != null) {
        try {
          await _registerIfAllowed();
        } catch (_) {
          /* Explicit enable offers retry. */
        }
      }
    });
    _tokens ??= FirebaseMessaging.instance.onTokenRefresh.listen((token) async {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null ||
          _stopping ||
          (await SharedPreferences.getInstance()).getBool('shared_push_$uid') !=
              true)
        return;
      try {
        final api = await sharedCareClient();
        await api.put('/sharing/device', data: {'token': token});
        if (_token != null && _token != token)
          await api.delete('/sharing/device', data: {'token': _token});
        _token = token;
      } catch (_) {
        /* Re-register on next enable/sign-in. */
      }
    });
    _messages ??= FirebaseMessaging.onMessage.listen((message) async {
      if (FirebaseAuth.instance.currentUser == null) return;
      SharedAlertInbox.updated();
      if (!await isEnabled()) return;
      try {
        await FlutterLocalNotificationsPlugin().show(
          id: int.tryParse(message.data['activity_id'] ?? '') ?? 730001,
          title: 'LullaByte',
          body: 'New shared care activity. Tap to view it.',
          payload: jsonEncode({'type': 'shared', ...message.data}),
          notificationDetails: NotificationDetails(
            android: AndroidNotificationDetails(
              'shared_care',
              'Shared care updates',
              channelDescription: 'Updates recorded by your baby’s care team',
              importance: Importance.high,
              priority: Priority.high,
              enableVibration: true,
              vibrationPattern: Int64List.fromList([
                0,
                300,
                150,
                300,
                150,
                300,
              ]),
            ),
          ),
        );
      } catch (_) {
        /* Activity remains available in the app. */
      }
      await SharedCareLiveSync.instance.refresh();
      SharedAlertInbox.updated();
    });
    await FlutterLocalNotificationsPlugin()
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(
          AndroidNotificationChannel(
            'shared_care',
            'Shared care updates',
            description: 'Updates recorded by your baby’s care team',
            importance: Importance.high,
            enableVibration: true,
            vibrationPattern: Int64List.fromList([0, 300, 150, 300, 150, 300]),
          ),
        );
  }

  static Future<void> _registerIfAllowed() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null ||
        _stopping ||
        (await SharedPreferences.getInstance()).getBool('shared_push_$uid') !=
            true)
      return;
    final settings = await FirebaseMessaging.instance.getNotificationSettings();
    if (settings.authorizationStatus != AuthorizationStatus.authorized &&
        settings.authorizationStatus != AuthorizationStatus.provisional)
      return;
    final token = await FirebaseMessaging.instance.getToken();
    if (token == null) throw StateError('Notification token unavailable.');
    final api = await sharedCareClient();
    await api.put('/sharing/device', data: {'token': token});
    _token = token;
  }

  static Future<void> enable() async {
    final permission = await FirebaseMessaging.instance.requestPermission();
    if (permission.authorizationStatus != AuthorizationStatus.authorized &&
        permission.authorizationStatus != AuthorizationStatus.provisional) {
      throw StateError('Allow notifications in phone settings, then retry.');
    }
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) throw StateError('Please sign in first.');
    _stopping = false;
    await (await SharedPreferences.getInstance()).setBool(
      'shared_push_$uid',
      true,
    );
    try {
      await _registerIfAllowed();
    } catch (_) {
      await (await SharedPreferences.getInstance()).setBool(
        'shared_push_$uid',
        false,
      );
      rethrow;
    }
  }

  static Future<void> disable() async {
    _stopping = true;
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null)
      await (await SharedPreferences.getInstance()).setBool(
        'shared_push_$uid',
        false,
      );
    final token = _token ?? await FirebaseMessaging.instance.getToken();
    try {
      if (token != null && FirebaseAuth.instance.currentUser != null) {
        final api = await sharedCareClient();
        await api.delete('/sharing/device', data: {'token': token});
      }
    } finally {
      // Invalidate the device token even when offline unregistration failed.
      await FirebaseMessaging.instance.deleteToken();
      _token = null;
    }
  }
}
