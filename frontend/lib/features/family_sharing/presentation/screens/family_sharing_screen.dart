import 'package:flutter/material.dart';

import '../../../../widgets/placeholder_screen.dart';

/// Placeholder screen for Family Sharing (SRS Section 10 placeholder).
///
/// Displays only a title, description, and AppBar — FamilySharingScreen will be
/// implemented in a subsequent feature-development milestone.
class FamilySharingScreen extends StatelessWidget {
  const FamilySharingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Family Sharing',
      description:
          'Inviting family members, caregivers, and doctors will be managed here (SRS Section 10.20).',
      icon: Icons.family_restroom_outlined,
    );
  }
}
