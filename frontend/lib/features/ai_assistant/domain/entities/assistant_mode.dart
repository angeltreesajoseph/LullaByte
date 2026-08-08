import 'package:flutter/material.dart';

import '../../../authentication/presentation/widgets/auth_palette.dart';

/// Which response path the assistant is currently using, driven
/// automatically by real device connectivity (see
/// `application/assistant_providers.dart`) rather than a manual toggle.
enum AssistantMode { offline, online }

extension AssistantModeX on AssistantMode {
  String get label => switch (this) {
        AssistantMode.offline => 'Offline Helper',
        AssistantMode.online => 'Online AI',
      };

  IconData get icon => switch (this) {
        AssistantMode.offline => Icons.wifi_off_rounded,
        AssistantMode.online => Icons.auto_awesome_rounded,
      };

  Color get color => switch (this) {
        AssistantMode.offline => AuthPalette.mint,
        AssistantMode.online => AuthPalette.lavenderMist,
      };
}
