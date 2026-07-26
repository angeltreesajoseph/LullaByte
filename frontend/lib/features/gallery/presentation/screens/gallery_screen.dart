import 'package:flutter/material.dart';

import '../../../../widgets/placeholder_screen.dart';

/// Placeholder screen for Gallery (SRS Section 10 placeholder).
///
/// Displays only a title, description, and AppBar — GalleryScreen will be
/// implemented in a subsequent feature-development milestone.
class GalleryScreen extends StatelessWidget {
  const GalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Gallery',
      description:
          'Photos and videos of your baby will appear here (SRS Section 10.12).',
      icon: Icons.photo_library_outlined,
    );
  }
}
