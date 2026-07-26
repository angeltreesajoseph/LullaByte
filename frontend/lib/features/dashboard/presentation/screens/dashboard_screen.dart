import 'package:flutter/material.dart';

import '../../../../widgets/placeholder_screen.dart';

/// Placeholder screen for Dashboard (SRS Section 10 placeholder).
///
/// Displays only a title, description, and AppBar — DashboardScreen will be
/// implemented in a subsequent feature-development milestone.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Dashboard',
      description:
          "Your baby's Daily Summary, Quick Actions, Recent Activities, and Statistics will appear here (SRS Section 10.5).",
      icon: Icons.dashboard_outlined,
    );
  }
}
