import 'package:flutter/material.dart';

import '../core/constants/app_constants.dart';

/// Reusable content card with consistent padding, radius, and elevation
/// (SAD Section 10.16.12, Data Visualization consistency principle),
/// used throughout Dashboard, Reports, and every tracker's summary views.
class AppCard extends StatelessWidget {
  const AppCard({
    required this.child,
    this.padding = const EdgeInsets.all(AppConstants.spacingMd),
    this.onTap,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final card = Card(
      child: Padding(padding: padding, child: child),
    );

    if (onTap == null) return card;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppConstants.radiusMd),
      child: card,
    );
  }
}
