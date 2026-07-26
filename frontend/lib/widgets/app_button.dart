import 'package:flutter/material.dart';

import '../core/constants/app_constants.dart';

/// Reusable primary action button with a built-in loading state and a
/// generously sized, accessibility-first tap target (SRS Section 15.4,
/// Large Buttons; minimum 48dp per [AppConstants.minTapTarget]).
class AppButton extends StatelessWidget {
  const AppButton({
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.variant = AppButtonVariant.primary,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final AppButtonVariant variant;

  @override
  Widget build(BuildContext context) {
    final child = isLoading
        ? const SizedBox(
            height: 22,
            width: 22,
            child: CircularProgressIndicator(strokeWidth: 2.5),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20),
                const SizedBox(width: AppConstants.spacingSm),
              ],
              Text(label),
            ],
          );

    final effectiveOnPressed = isLoading ? null : onPressed;

    switch (variant) {
      case AppButtonVariant.primary:
        return ElevatedButton(onPressed: effectiveOnPressed, child: child);
      case AppButtonVariant.outlined:
        return OutlinedButton(onPressed: effectiveOnPressed, child: child);
      case AppButtonVariant.text:
        return TextButton(onPressed: effectiveOnPressed, child: child);
    }
  }
}

enum AppButtonVariant { primary, outlined, text }
