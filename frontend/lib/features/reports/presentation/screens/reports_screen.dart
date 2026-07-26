import 'package:flutter/material.dart';

import '../../../../widgets/placeholder_screen.dart';

/// Placeholder screen for Reports and Analytics (SRS Section 10 placeholder).
///
/// Displays only a title, description, and AppBar — ReportsScreen will be
/// implemented in a subsequent feature-development milestone.
class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Reports and Analytics',
      description:
          'Daily, weekly, and monthly reports across every tracked module will appear here (SRS Section 10.16).',
      icon: Icons.bar_chart_outlined,
    );
  }
}
