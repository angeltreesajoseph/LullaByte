import 'package:flutter/material.dart';

import 'permission_level.dart';

/// A family member or caregiver with access to Lily's care data.
///
/// [permission] and [isPending] are mutable — this is a plain local model
/// mutated directly by the Family Sharing screen's state (permission
/// changes, new invites); there is no backend or persistence layer yet.
class SharedMember {
  SharedMember({
    required this.id,
    required this.name,
    required this.relationship,
    required this.avatarIcon,
    required this.avatarColor,
    required this.permission,
    this.isPending = false,
  });

  final String id;
  final String name;
  final String relationship;
  final IconData avatarIcon;
  final Color avatarColor;
  PermissionLevel permission;
  bool isPending;
}
