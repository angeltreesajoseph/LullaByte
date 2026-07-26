import 'package:flutter/material.dart';

import '../../../../widgets/placeholder_screen.dart';

/// Placeholder screen for Settings (SRS Section 10 placeholder).
///
/// Displays only a title, description, and AppBar — SettingsScreen will be
/// implemented in a subsequent feature-development milestone.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Settings',
      description:
          'Profile, theme, language, privacy, security, and accessibility settings will appear here (SRS Section 10.21).',
      icon: Icons.settings_outlined,
    );
  }
}
