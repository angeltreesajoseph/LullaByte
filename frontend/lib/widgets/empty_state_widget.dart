import 'package:flutter/material.dart';

import '../core/constants/app_constants.dart';

/// Reusable empty-state widget shown when a list/history view has no
/// records yet (e.g. SRS Section 10.7.9 Feeding History, Section 10.5.4
/// Recent Activities) — friendly, non-alarming, and icon-led.
class EmptyStateWidget extends StatelessWidget {
  const EmptyStateWidget({
    required this.message,
    this.icon = Icons.inbox_outlined,
    super.key,
  });

  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingLg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: Theme.of(context).colorScheme.outline),
            const SizedBox(height: AppConstants.spacingMd),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
