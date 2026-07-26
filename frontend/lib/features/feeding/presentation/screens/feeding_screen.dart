import 'package:flutter/material.dart';

import '../../../../widgets/placeholder_screen.dart';

/// Placeholder screen for Feeding Tracker (SRS Section 10 placeholder).
///
/// Displays only a title, description, and AppBar — FeedingScreen will be
/// implemented in a subsequent feature-development milestone.
class FeedingScreen extends StatelessWidget {
  const FeedingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Feeding Tracker',
      description:
          'Breastfeeding, bottle, formula, and solid feeding logs will appear here (SRS Section 10.7).',
      icon: Icons.local_drink_outlined,
    );
  }
}
