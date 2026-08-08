import 'package:flutter/material.dart';

import '../../../authentication/presentation/widgets/auth_palette.dart';
import 'milestone_models.dart';

/// Single shared, in-memory list of age-group milestone data for Lily.
/// Both the "All Milestones" list screen and the "Milestone Detail" screen
/// read and mutate this same instance, so a checklist item toggled in the
/// detail view is reflected the moment the user navigates back to the
/// list — no backend, Firebase, or database, kept entirely local to the
/// Milestones feature for this session.
final List<AgeGroupMilestones> mockMilestoneAgeGroups = [
  AgeGroupMilestones(
    shortLabel: '0–2 mo',
    fullLabel: '0–2 Months',
    icon: Icons.child_friendly_rounded,
    color: AuthPalette.blushPink,
    categories: [
      MilestoneCategory(
        type: MilestoneCategoryType.cognitive,
        items: [
          MilestoneItem(name: 'Focuses on faces', achieved: true),
          MilestoneItem(name: 'Follows objects with eyes', achieved: true),
          MilestoneItem(name: "Recognizes parent's voice", achieved: true),
        ],
      ),
      MilestoneCategory(
        type: MilestoneCategoryType.language,
        items: [
          MilestoneItem(name: 'Startles at loud sounds', achieved: true),
          MilestoneItem(name: 'Makes cooing sounds', achieved: true),
          MilestoneItem(name: 'Cries to express needs', achieved: true),
        ],
      ),
      MilestoneCategory(
        type: MilestoneCategoryType.motor,
        items: [
          MilestoneItem(name: 'Lifts head during tummy time', achieved: true),
          MilestoneItem(name: 'Moves arms and legs actively', achieved: true),
          MilestoneItem(name: 'Brings hands to face', achieved: true),
        ],
      ),
      MilestoneCategory(
        type: MilestoneCategoryType.social,
        items: [
          MilestoneItem(name: 'Begins to smile at people', achieved: true),
          MilestoneItem(name: 'Calms when spoken to', achieved: true),
        ],
      ),
    ],
  ),
  AgeGroupMilestones(
    shortLabel: '2–4 mo',
    fullLabel: '2–4 Months',
    icon: Icons.emoji_emotions_rounded,
    color: AuthPalette.powderBlue,
    categories: [
      MilestoneCategory(
        type: MilestoneCategoryType.cognitive,
        items: [
          MilestoneItem(name: 'Watches faces closely', achieved: true),
          MilestoneItem(name: 'Begins to follow moving objects', achieved: true),
          MilestoneItem(name: 'Recognizes familiar people at a distance', achieved: true),
        ],
      ),
      MilestoneCategory(
        type: MilestoneCategoryType.language,
        items: [
          MilestoneItem(name: 'Coos and makes vowel sounds', achieved: true),
          MilestoneItem(name: 'Turns head toward sounds', achieved: true),
        ],
      ),
      MilestoneCategory(
        type: MilestoneCategoryType.motor,
        items: [
          MilestoneItem(name: 'Holds head steady when upright', achieved: true),
          MilestoneItem(name: 'Pushes up on arms during tummy time', achieved: true),
          MilestoneItem(name: 'Opens and shuts hands', achieved: false),
        ],
      ),
      MilestoneCategory(
        type: MilestoneCategoryType.social,
        items: [
          MilestoneItem(name: 'Smiles spontaneously', achieved: true),
          MilestoneItem(name: 'Enjoys playing with people', achieved: false),
        ],
      ),
    ],
  ),
  AgeGroupMilestones(
    shortLabel: '4–6 mo',
    fullLabel: '4–6 Months',
    icon: Icons.pan_tool_rounded,
    color: AuthPalette.mint,
    categories: [
      MilestoneCategory(
        type: MilestoneCategoryType.cognitive,
        items: [
          MilestoneItem(name: 'Reaches for toys with one hand', achieved: true),
          MilestoneItem(name: 'Explores objects by mouthing them', achieved: false),
        ],
      ),
      MilestoneCategory(
        type: MilestoneCategoryType.language,
        items: [
          MilestoneItem(name: 'Babbles with expression', achieved: true),
          MilestoneItem(name: 'Responds to own name', achieved: false),
        ],
      ),
      MilestoneCategory(
        type: MilestoneCategoryType.motor,
        items: [
          MilestoneItem(name: 'Rolls over both ways', achieved: false),
          MilestoneItem(name: 'Sits with support', achieved: false),
          MilestoneItem(name: 'Brings objects to mouth', achieved: false),
        ],
      ),
      MilestoneCategory(
        type: MilestoneCategoryType.social,
        items: [
          MilestoneItem(name: 'Laughs out loud', achieved: false),
          MilestoneItem(name: 'Likes to look at self in mirror', achieved: false),
        ],
      ),
    ],
  ),
  AgeGroupMilestones(
    shortLabel: '6–9 mo',
    fullLabel: '6–9 Months',
    icon: Icons.accessibility_new_rounded,
    color: AuthPalette.lavenderMist,
    categories: [
      MilestoneCategory(
        type: MilestoneCategoryType.cognitive,
        items: [
          MilestoneItem(name: 'Looks for dropped objects'),
          MilestoneItem(name: 'Understands object permanence'),
        ],
      ),
      MilestoneCategory(
        type: MilestoneCategoryType.language,
        items: [
          MilestoneItem(name: "Says 'mama' or 'dada' (non-specific)"),
          MilestoneItem(name: 'Responds to simple requests'),
        ],
      ),
      MilestoneCategory(
        type: MilestoneCategoryType.motor,
        items: [
          MilestoneItem(name: 'Sits without support'),
          MilestoneItem(name: 'Crawls forward on belly'),
          MilestoneItem(name: 'Transfers objects hand to hand'),
        ],
      ),
      MilestoneCategory(
        type: MilestoneCategoryType.social,
        items: [
          MilestoneItem(name: 'Shows stranger anxiety'),
          MilestoneItem(name: 'Has favorite toys'),
        ],
      ),
    ],
  ),
  AgeGroupMilestones(
    shortLabel: '9–12 mo',
    fullLabel: '9–12 Months',
    icon: Icons.emoji_people_rounded,
    color: AuthPalette.softCoral,
    categories: [
      MilestoneCategory(
        type: MilestoneCategoryType.cognitive,
        items: [
          MilestoneItem(name: 'Explores objects in different ways'),
          MilestoneItem(name: 'Finds hidden objects easily'),
        ],
      ),
      MilestoneCategory(
        type: MilestoneCategoryType.language,
        items: [
          MilestoneItem(name: 'Says first clear word'),
          MilestoneItem(name: 'Waves bye-bye'),
        ],
      ),
      MilestoneCategory(
        type: MilestoneCategoryType.motor,
        items: [
          MilestoneItem(name: 'Pulls to stand'),
          MilestoneItem(name: 'Cruises along furniture'),
        ],
      ),
      MilestoneCategory(
        type: MilestoneCategoryType.social,
        items: [
          MilestoneItem(name: 'Shows clear preferences for people and toys'),
          MilestoneItem(name: 'Repeats sounds and actions for attention'),
        ],
      ),
    ],
  ),
];
