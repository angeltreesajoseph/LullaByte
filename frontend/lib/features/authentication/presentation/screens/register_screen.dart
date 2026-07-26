import 'package:flutter/material.dart';

import '../../../../widgets/placeholder_screen.dart';

/// Placeholder screen for Create Account (SRS Section 10 placeholder).
///
/// Displays only a title, description, and AppBar — RegisterScreen will be
/// implemented in a subsequent feature-development milestone.
class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Create Account',
      description:
          'New parent and caregiver account registration will be available here (SRS Section 10.1.1).',
      icon: Icons.person_add_alt_outlined,
    );
  }
}
