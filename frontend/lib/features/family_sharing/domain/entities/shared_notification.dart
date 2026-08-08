import 'package:flutter/material.dart';

import '../../../authentication/presentation/widgets/auth_palette.dart';

enum SharedNotificationType { feeding, cry, sleep, milestone }

extension SharedNotificationTypeX on SharedNotificationType {
  IconData get icon => switch (this) {
        SharedNotificationType.feeding => Icons.local_drink_rounded,
        SharedNotificationType.cry => Icons.graphic_eq_rounded,
        SharedNotificationType.sleep => Icons.bedtime_rounded,
        SharedNotificationType.milestone => Icons.emoji_events_rounded,
      };

  Color get color => switch (this) {
        SharedNotificationType.feeding => AuthPalette.powderBlue,
        SharedNotificationType.cry => AuthPalette.softCoral,
        SharedNotificationType.sleep => AuthPalette.lavenderMist,
        SharedNotificationType.milestone => AuthPalette.mint,
      };
}

/// A single mock notification shared across the family/caregiver circle.
class SharedNotification {
  const SharedNotification({
    required this.type,
    required this.message,
    required this.timeLabel,
  });

  final SharedNotificationType type;
  final String message;
  final String timeLabel;
}
