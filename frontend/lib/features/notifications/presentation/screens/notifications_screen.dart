import 'package:flutter/material.dart';

import '../../../../widgets/placeholder_screen.dart';

/// Placeholder screen for Notifications (SRS Section 10 placeholder).
///
/// Displays only a title, description, and AppBar — NotificationsScreen will be
/// implemented in a subsequent feature-development milestone.
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Notifications',
      description:
          'Reminders, alerts, and notification history will appear here (SRS Section 10.17).',
      icon: Icons.notifications_outlined,
    );
  }
}
