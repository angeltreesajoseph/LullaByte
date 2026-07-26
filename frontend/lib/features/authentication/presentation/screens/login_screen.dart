import 'package:flutter/material.dart';

import '../../../../widgets/placeholder_screen.dart';

/// Placeholder screen for Log In (SRS Section 10 placeholder).
///
/// Displays only a title, description, and AppBar — LoginScreen will be
/// implemented in a subsequent feature-development milestone.
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Log In',
      description:
          'Email/password, Google Sign-In, and Phone OTP login will be available here (SRS Section 10.1).',
      icon: Icons.login,
    );
  }
}
