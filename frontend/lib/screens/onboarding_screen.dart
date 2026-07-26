import 'package:flutter/material.dart';

import '../widgets/placeholder_screen.dart';

/// Placeholder screen for Welcome to LullaByte (SRS Section 10 placeholder).
///
/// Displays only a title, description, and AppBar — OnboardingScreen will be
/// implemented in a subsequent feature-development milestone.
class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Welcome to LullaByte',
      description:
          'A quick introduction to cry analysis, offline tracking, and accessibility features will appear here.',
      icon: Icons.waving_hand_outlined,
    );
  }
}
