import 'package:flutter/material.dart';

/// Shared "calm, safe, caring — 2 AM newborn care" pastel palette used
/// across the Authentication feature's hero screens (Login, Register, ...).
///
/// Deliberately kept local to the Authentication feature — not merged into
/// `core/theme/app_colors.dart` — since this is a bespoke visual treatment
/// for these specific screens, not the app's ambient Material theme.
class AuthPalette {
  const AuthPalette._();

  static const blushPink = Color(0xFFFDE7EF);
  static const softCoral = Color(0xFFF48FB1);
  static const powderBlue = Color(0xFFA7C7E7);
  static const lavenderMist = Color(0xFFD8C4F1);
  static const warmCream = Color(0xFFFFF9F6);
  static const mint = Color(0xFFB8E6C8);

  static const textDark = Color(0xFF4A3B47);
  static const textMuted = Color(0xFF8C7B87);

  static const error = Color(0xFFE0645B);
  static const strengthWeak = Color(0xFFE0645B);
  static const strengthFair = Color(0xFFE0A94E);
  static const strengthGood = powderBlue;
  static const strengthStrong = mint;
}
