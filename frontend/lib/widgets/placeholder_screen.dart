import 'package:flutter/material.dart';

import '../core/constants/app_constants.dart';

/// Generic placeholder screen shared by every not-yet-implemented feature
/// screen registered in `core/router/app_router.dart`.
///
/// Displays only a title and a short description inside a Scaffold with an
/// AppBar, per the application-foundation scope — no feature logic.
class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({
    required this.title,
    required this.description,
    this.icon = Icons.construction_outlined,
    super.key,
  });

  final String title;
  final String description;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.spacingLg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 56, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: AppConstants.spacingMd),
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppConstants.spacingSm),
              Text(
                description,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
