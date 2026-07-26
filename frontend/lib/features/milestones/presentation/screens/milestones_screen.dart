import 'package:flutter/material.dart';

import '../../../../widgets/placeholder_screen.dart';

/// Placeholder screen for Milestone Tracking (SRS Section 10 placeholder).
///
/// Displays only a title, description, and AppBar — MilestonesScreen will be
/// implemented in a subsequent feature-development milestone.
class MilestonesScreen extends StatelessWidget {
  const MilestonesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Milestone Tracking',
      description:
          'The developmental milestone timeline and achievements will appear here (SRS Section 10.11).',
      icon: Icons.emoji_events_outlined,
    );
  }
}
