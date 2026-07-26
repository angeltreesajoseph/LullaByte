import 'package:flutter/material.dart';

import '../../../../widgets/placeholder_screen.dart';

/// Placeholder screen for Baby Profile (SRS Section 10 placeholder).
///
/// Displays only a title, description, and AppBar — BabyProfileScreen will be
/// implemented in a subsequent feature-development milestone.
class BabyProfileScreen extends StatelessWidget {
  const BabyProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Baby Profile',
      description:
          'Baby details, medical information, allergies, and emergency contacts will appear here (SRS Section 10.13).',
      icon: Icons.badge_outlined,
    );
  }
}
