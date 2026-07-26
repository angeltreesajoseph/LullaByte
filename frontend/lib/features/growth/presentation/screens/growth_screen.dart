import 'package:flutter/material.dart';

import '../../../../widgets/placeholder_screen.dart';

/// Placeholder screen for Growth Records (SRS Section 10 placeholder).
///
/// Displays only a title, description, and AppBar — GrowthScreen will be
/// implemented in a subsequent feature-development milestone.
class GrowthScreen extends StatelessWidget {
  const GrowthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Growth Records',
      description:
          'Weight, height, and head circumference tracking with growth charts will appear here (SRS Section 10.14).',
      icon: Icons.show_chart,
    );
  }
}
