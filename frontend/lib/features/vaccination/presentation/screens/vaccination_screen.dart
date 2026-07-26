import 'package:flutter/material.dart';

import '../../../../widgets/placeholder_screen.dart';

/// Placeholder screen for Vaccination Management (SRS Section 10 placeholder).
///
/// Displays only a title, description, and AppBar — VaccinationScreen will be
/// implemented in a subsequent feature-development milestone.
class VaccinationScreen extends StatelessWidget {
  const VaccinationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Vaccination Management',
      description:
          'The vaccination schedule, appointments, and reminders will appear here (SRS Section 10.10).',
      icon: Icons.vaccines_outlined,
    );
  }
}
