import 'package:flutter/material.dart';

/// LullaByte healthcare color palette.
///
/// Soft, low-stimulation tones by design: this application is used by
/// sleep-deprived parents (often one-handed, at night) and must never rely
/// on color alone to convey meaning (SRS Section 15.6, Section 15.10).
class AppColors {
  const AppColors._();

  // Primary — Soft Blue
  static const Color primary = Color(0xFF5C8FC7);
  static const Color primaryLight = Color(0xFFAFCBE8);
  static const Color primaryDark = Color(0xFF335A85);

  // Secondary — Soft Green
  static const Color secondary = Color(0xFF6FBF8B);
  static const Color secondaryLight = Color(0xFFC3EAD3);
  static const Color secondaryDark = Color(0xFF3E8B60);

  // Neutrals — White / Off-White
  static const Color white = Color(0xFFFFFFFF);
  static const Color offWhite = Color(0xFFF6FAFC);
  static const Color surfaceLight = Color(0xFFFDFEFF);
  static const Color surfaceDark = Color(0xFF1B2027);
  static const Color backgroundDark = Color(0xFF12161B);

  // Text
  static const Color textPrimaryLight = Color(0xFF1F2A37);
  static const Color textSecondaryLight = Color(0xFF5B6B79);
  static const Color textPrimaryDark = Color(0xFFECF1F5);
  static const Color textSecondaryDark = Color(0xFFA9B7C3);

  // Pastel accents
  static const Color pastelYellow = Color(0xFFFCE8A6);
  static const Color pastelPink = Color(0xFFF6C9D9);
  static const Color pastelLavender = Color(0xFFD9CDF2);
  static const Color pastelPeach = Color(0xFFFAD3BE);

  // Status colors — deliberately muted, never harsh, and always paired
  // with an icon or label in the UI (never color alone; SRS Section 15.6).
  static const Color success = secondary;
  static const Color warning = Color(0xFFE0A94E);
  static const Color error = Color(0xFFD9736F);
  static const Color info = primary;

  static const Color divider = Color(0xFFE1E8ED);
  static const Color dividerDark = Color(0xFF2A313A);
}
