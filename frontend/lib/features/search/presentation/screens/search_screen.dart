import 'package:flutter/material.dart';

import '../../../../widgets/placeholder_screen.dart';

/// Placeholder screen for Search (SRS Section 10 placeholder).
///
/// Displays only a title, description, and AppBar — SearchScreen will be
/// implemented in a subsequent feature-development milestone.
class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Search',
      description:
          'Global search across every tracked record will appear here (SRS Section 10.19).',
      icon: Icons.search,
    );
  }
}
