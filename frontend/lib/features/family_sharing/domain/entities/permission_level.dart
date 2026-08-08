import 'package:flutter/material.dart';

import '../../../authentication/presentation/widgets/auth_palette.dart';

/// The four access levels a shared family member or caregiver can hold.
enum PermissionLevel { viewOnly, caregiver, fullAccess, alertOnly }

extension PermissionLevelX on PermissionLevel {
  String get label => switch (this) {
        PermissionLevel.viewOnly => 'View Only',
        PermissionLevel.caregiver => 'Caregiver',
        PermissionLevel.fullAccess => 'Full Access',
        PermissionLevel.alertOnly => 'Alert Only',
      };

  IconData get icon => switch (this) {
        PermissionLevel.viewOnly => Icons.visibility_outlined,
        PermissionLevel.caregiver => Icons.diversity_3_rounded,
        PermissionLevel.fullAccess => Icons.verified_user_rounded,
        PermissionLevel.alertOnly => Icons.notifications_active_outlined,
      };

  Color get color => switch (this) {
        PermissionLevel.viewOnly => AuthPalette.powderBlue,
        PermissionLevel.caregiver => AuthPalette.mint,
        PermissionLevel.fullAccess => AuthPalette.softCoral,
        PermissionLevel.alertOnly => AuthPalette.lavenderMist,
      };

  /// Shown in the "Permission Details" bottom sheet.
  List<String> get canView => switch (this) {
        PermissionLevel.viewOnly => const [
            'All care logs and charts',
            'Growth, sleep, feeding, and diaper history',
            'Milestones and vaccination records',
          ],
        PermissionLevel.caregiver => const [
            'All care logs and charts',
            "Today's schedule and reminders",
            'Cry analysis history',
          ],
        PermissionLevel.fullAccess => const [
            'Everything in the app',
            'Family member list and permissions',
            'Invite and notification settings',
          ],
        PermissionLevel.alertOnly => const [
            'Shared notifications only',
            'Live care session status',
          ],
      };

  List<String> get canAdd => switch (this) {
        PermissionLevel.viewOnly => const ['Nothing — read-only access'],
        PermissionLevel.caregiver => const [
            'Feeding, sleep, and diaper entries',
            'Cry recordings for analysis',
          ],
        PermissionLevel.fullAccess => const [
            'Any entry or record',
            'New caregivers and permissions',
          ],
        PermissionLevel.alertOnly => const ['Nothing — notifications only'],
      };

  List<String> get cannotModify => switch (this) {
        PermissionLevel.viewOnly => const [
            'Cannot add or edit any entries',
            'Cannot manage other caregivers',
          ],
        PermissionLevel.caregiver => const [
            'Cannot change family permissions',
            'Cannot remove other caregivers',
          ],
        PermissionLevel.fullAccess => const [
            'Cannot remove the primary parent',
            "Cannot delete Lily's profile",
          ],
        PermissionLevel.alertOnly => const [
            'Cannot view detailed logs or charts',
            'Cannot add or edit entries',
          ],
      };
}
