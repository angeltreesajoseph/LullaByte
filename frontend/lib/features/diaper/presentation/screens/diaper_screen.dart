import 'package:flutter/material.dart';

import '../../../../widgets/placeholder_screen.dart';

/// Placeholder screen for Diaper Tracker (SRS Section 10 placeholder).
///
/// Displays only a title, description, and AppBar — DiaperScreen will be
/// implemented in a subsequent feature-development milestone.
class DiaperScreen extends StatelessWidget {
  const DiaperScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Diaper Tracker',
      description:
          'Diaper change logging and statistics will appear here (SRS Section 10.9).',
      icon: Icons.child_friendly_outlined,
    );
  }
}
