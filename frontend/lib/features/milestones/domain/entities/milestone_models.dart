import 'package:flutter/material.dart';

import '../../../authentication/presentation/widgets/auth_palette.dart';

/// Milestone entity classes shared between the "All Milestones" list
/// screen and the "Milestone Detail" screen. Kept as plain mutable model
/// classes (not immutable/copyWith-style) so a checklist item toggled in
/// the detail screen is reflected immediately when the user navigates
/// back to the list — see `milestone_mock_data.dart` for the single
/// shared, in-memory instance both screens read from.
enum MilestoneCategoryType { cognitive, language, motor, social }

extension MilestoneCategoryTypeX on MilestoneCategoryType {
  String get label => switch (this) {
        MilestoneCategoryType.cognitive => 'Cognitive Milestones',
        MilestoneCategoryType.language => 'Language & Communication',
        MilestoneCategoryType.motor => 'Motor Skills',
        MilestoneCategoryType.social => 'Social & Emotional',
      };

  IconData get icon => switch (this) {
        MilestoneCategoryType.cognitive => Icons.psychology_rounded,
        MilestoneCategoryType.language => Icons.record_voice_over_rounded,
        MilestoneCategoryType.motor => Icons.directions_run_rounded,
        MilestoneCategoryType.social => Icons.favorite_rounded,
      };

  Color get color => switch (this) {
        MilestoneCategoryType.cognitive => AuthPalette.lavenderMist,
        MilestoneCategoryType.language => AuthPalette.powderBlue,
        MilestoneCategoryType.motor => AuthPalette.mint,
        MilestoneCategoryType.social => AuthPalette.softCoral,
      };
}

class MilestoneItem {
  MilestoneItem({required this.name, this.achieved = false});

  final String name;
  bool achieved;
}

class MilestoneCategory {
  MilestoneCategory({required this.type, required this.items});

  final MilestoneCategoryType type;
  final List<MilestoneItem> items;

  int get completedCount => items.where((item) => item.achieved).length;
  int get totalCount => items.length;
}

class AgeGroupMilestones {
  AgeGroupMilestones({
    required this.shortLabel,
    required this.fullLabel,
    required this.icon,
    required this.color,
    required this.categories,
  });

  final String shortLabel;
  final String fullLabel;
  final IconData icon;
  final Color color;
  final List<MilestoneCategory> categories;

  int get completedCount => categories.fold(0, (sum, category) => sum + category.completedCount);
  int get totalCount => categories.fold(0, (sum, category) => sum + category.totalCount);
}
