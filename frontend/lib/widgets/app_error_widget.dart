import 'package:flutter/material.dart';

import '../core/constants/app_constants.dart';
import 'app_button.dart';

/// Reusable error state widget, pairing an icon with a plain-language
/// message (never color alone, per SRS Section 15.6) and an optional retry
/// action — the visual counterpart to the Error Handling subsections
/// defined per module throughout SRS Section 10.
class AppErrorWidget extends StatelessWidget {
  const AppErrorWidget({
    required this.message,
    this.onRetry,
    super.key,
  });

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingLg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: colorScheme.error),
            const SizedBox(height: AppConstants.spacingMd),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppConstants.spacingLg),
              AppButton(label: 'Try Again', onPressed: onRetry),
            ],
          ],
        ),
      ),
    );
  }
}
