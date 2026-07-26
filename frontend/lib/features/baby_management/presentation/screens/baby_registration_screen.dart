import 'package:flutter/material.dart';

import '../../../../widgets/placeholder_screen.dart';

/// Placeholder screen for Baby Registration (SRS Section 10 placeholder).
///
/// Displays only a title, description, and AppBar — BabyRegistrationScreen will be
/// implemented in a subsequent feature-development milestone.
class BabyRegistrationScreen extends StatelessWidget {
  const BabyRegistrationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Baby Registration',
      description:
          'Baby details, birth information, and twin registration will be handled here (SRS Section 10.3, 10.4).',
      icon: Icons.child_care_outlined,
    );
  }
}
