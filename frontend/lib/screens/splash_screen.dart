import 'package:flutter/material.dart';

import '../widgets/placeholder_screen.dart';

/// Placeholder screen for LullaByte (SRS Section 10 placeholder).
///
/// Displays only a title, description, and AppBar — SplashScreen will be
/// implemented in a subsequent feature-development milestone.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'LullaByte',
      description:
          'AI Powered Newborn Care Assistant. Preparing your experience...',
      icon: Icons.nightlight_round,
    );
  }
}
