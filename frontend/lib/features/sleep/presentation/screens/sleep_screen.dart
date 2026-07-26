import 'package:flutter/material.dart';

import '../../../../widgets/placeholder_screen.dart';

/// Placeholder screen for Sleep Tracker (SRS Section 10 placeholder).
///
/// Displays only a title, description, and AppBar — SleepScreen will be
/// implemented in a subsequent feature-development milestone.
class SleepScreen extends StatelessWidget {
  const SleepScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Sleep Tracker',
      description:
          'Sleep session tracking and day/night statistics will appear here (SRS Section 10.8).',
      icon: Icons.bedtime_outlined,
    );
  }
}
