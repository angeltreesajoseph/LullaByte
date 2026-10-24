import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../authentication/presentation/widgets/auth_background.dart';
import '../../../authentication/presentation/widgets/auth_palette.dart';

/// Uses Android's actual channel preferences, not an independent app toggle.
class NotificationPreferencesScreen extends StatefulWidget {
  const NotificationPreferencesScreen({super.key});
  @override
  State<NotificationPreferencesScreen> createState() => _PreferencesState();
}

class _PreferencesState extends State<NotificationPreferencesScreen>
    with WidgetsBindingObserver {
  static const _categories = {
    'shared_care': 'Shared care updates',
    'feeding': 'Feeding reminders',
    'vaccinations': 'Vaccination reminders',
    'cry_results': 'Cry analysis ready',
  };
  final _plugin = FlutterLocalNotificationsPlugin();
  List<AndroidNotificationChannel> _channels = [];
  bool? _allowed;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refresh();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _refresh();
  }

  Future<void> _refresh() async {
    try {
      final android = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      if (android == null) return;
      for (final category in _categories.entries) {
        await android.createNotificationChannel(
          AndroidNotificationChannel(
            category.key,
            category.value,
            importance: Importance.high,
            enableVibration: true,
            playSound: category.key != 'cry_results',
            vibrationPattern: Int64List.fromList(
              category.key == 'shared_care'
                  ? [0, 300, 150, 300, 150, 300]
                  : category.key == 'cry_results'
                  ? [0, 500]
                  : [0, 400, 200, 400],
            ),
          ),
        );
      }
      final channels = await android.getNotificationChannels();
      final allowed = await android.areNotificationsEnabled();
      if (mounted)
        setState(() {
          _channels = channels ?? [];
          _allowed = allowed;
        });
    } catch (_) {
      _message(
        'Could not read phone settings. Try opening notification settings.',
      );
    }
  }

  void _message(String text) {
    if (mounted)
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _settings([String? channel]) async {
    try {
      if (Theme.of(context).platform == TargetPlatform.android) {
        await const MethodChannel(
          'lullabyte/notification_settings',
        ).invokeMethod<void>('open', {'channel': channel});
      } else {
        await openAppSettings();
      }
    } catch (_) {
      _message(
        'Please open phone Settings → Apps → LullaByte → Notifications.',
      );
    }
  }

  Future<void> _test(String id, String name) async {
    setState(() => _busy = true);
    try {
      final android = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      if (android != null &&
          await android.requestNotificationsPermission() != true) {
        _message('Allow notifications in phone settings to test alerts.');
        return;
      }
      await _plugin.show(
        id: 740100 + _categories.keys.toList().indexOf(id),
        title: 'LullaByte · Test notification',
        body: '$name: check this alert and feel for vibration.',
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            id,
            name,
            importance: Importance.high,
            priority: Priority.high,
            enableVibration: true,
          ),
          iOS: const DarwinNotificationDetails(),
        ),
      );
      _message(
        'Test requested. Check the notification drawer. Phone settings control vibration.',
      );
      await _refresh();
    } catch (_) {
      _message(
        'Could not send test notification. Check phone notification settings.',
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AuthPalette.warmCream,
    appBar: AppBar(
      title: const Text('Notification preferences'),
      backgroundColor: AuthPalette.warmCream,
    ),
    body: Stack(
      children: [
        const Positioned.fill(child: AuthBackgroundGradient()),
        ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              'Alerts you can see and feel',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'On this phone. Use phone settings to switch sound and vibration independently. Alerts also remain in the app’s bell inbox.',
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => _settings(),
              icon: const Icon(Icons.settings_outlined),
              label: Text(
                _allowed == false
                    ? 'Notifications blocked · Open settings'
                    : 'Phone notification settings',
              ),
            ),
            for (final category in _categories.entries)
              _card(category.key, category.value),
            const SizedBox(height: 12),
            const Text(
              'Silent mode, Do Not Disturb and battery restrictions may affect alerts. Existing categories keep your phone’s settings. Tests do not enable shared-care subscriptions or change saved reminders.',
            ),
          ],
        ),
      ],
    ),
  );

  Widget _card(String id, String name) {
    final matches = _channels.where((c) => c.id == id);
    final channel = matches.isEmpty ? null : matches.first;
    final status = channel == null
        ? 'Check sound and vibration in phone settings'
        : channel.importance == Importance.none
        ? 'Blocked in phone settings'
        : 'Vibration: ${channel.enableVibration ? "on" : "off"} · Sound: ${channel.playSound ? "on" : "off"}';
    return Card(
      margin: const EdgeInsets.only(top: 14),
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(status),
            Wrap(
              spacing: 8,
              children: [
                TextButton.icon(
                  onPressed: () => _settings(id),
                  icon: const Icon(Icons.vibration),
                  label: const Text('Sound & vibration'),
                ),
                TextButton.icon(
                  onPressed: _busy ? null : () => _test(id, name),
                  icon: const Icon(Icons.notifications_active_outlined),
                  label: const Text('Test alert'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
