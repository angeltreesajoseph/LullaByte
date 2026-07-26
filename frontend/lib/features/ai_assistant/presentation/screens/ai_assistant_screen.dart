import 'package:flutter/material.dart';

import '../../../../widgets/placeholder_screen.dart';

/// Placeholder screen for AI Parenting Assistant (SRS Section 10 placeholder).
///
/// Displays only a title, description, and AppBar — AiAssistantScreen will be
/// implemented in a subsequent feature-development milestone.
class AiAssistantScreen extends StatelessWidget {
  const AiAssistantScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'AI Parenting Assistant',
      description:
          'Chat-based parenting guidance will appear here (SRS Section 10.15).',
      icon: Icons.smart_toy_outlined,
    );
  }
}
