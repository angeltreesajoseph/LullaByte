import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Builds the LullaByte Light and Dark Material 3 themes.
///
/// Colors are seeded from the healthcare palette defined in [AppColors]
/// (SAD Section 5.2; SRS Section 15). Both themes independently satisfy
/// the color-contrast expectations of SRS Section 15.6 and Section 15.10
/// (High Contrast Mode is a distinct, separately configurable theme layer
/// handled by the Accessibility Settings feature, not by this file).
class AppTheme {
  const AppTheme._();

  static const double _radius = 16;

  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      error: AppColors.error,
      surface: AppColors.surfaceLight,
    );

    return _base(colorScheme).copyWith(
      scaffoldBackgroundColor: AppColors.offWhite,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.offWhite,
        foregroundColor: AppColors.textPrimaryLight,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: const TextStyle(
          color: AppColors.textPrimaryLight,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      dividerColor: AppColors.divider,
      textTheme: _textTheme(AppColors.textPrimaryLight, AppColors.textSecondaryLight),
    );
  }

  static ThemeData get dark {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primaryLight,
      brightness: Brightness.dark,
      primary: AppColors.primaryLight,
      secondary: AppColors.secondaryLight,
      error: AppColors.error,
      surface: AppColors.surfaceDark,
    );

    return _base(colorScheme).copyWith(
      scaffoldBackgroundColor: AppColors.backgroundDark,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.backgroundDark,
        foregroundColor: AppColors.textPrimaryDark,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: const TextStyle(
          color: AppColors.textPrimaryDark,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      dividerColor: AppColors.dividerDark,
      textTheme: _textTheme(AppColors.textPrimaryDark, AppColors.textSecondaryDark),
    );
  }

  static ThemeData _base(ColorScheme colorScheme) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      // No custom font family is bundled yet — Material 3's default
      // typography (Roboto) is used until frontend/assets/fonts/ is
      // populated (see pubspec.yaml).
      cardTheme: CardThemeData(
        elevation: 0,
        color: colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_radius),
          side: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.4)),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_radius),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_radius),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_radius),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_radius),
          borderSide: BorderSide(color: colorScheme.error, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_radius)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_radius)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_radius)),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        backgroundColor: colorScheme.surface,
        indicatorColor: colorScheme.primaryContainer,
      ),
      // Large, accessibility-first tap targets throughout (SRS Section 15.4).
      visualDensity: VisualDensity.comfortable,
    );
  }

  static TextTheme _textTheme(Color primaryText, Color secondaryText) {
    return TextTheme(
      headlineSmall: TextStyle(color: primaryText, fontWeight: FontWeight.w700, fontSize: 24),
      titleLarge: TextStyle(color: primaryText, fontWeight: FontWeight.w700, fontSize: 20),
      titleMedium: TextStyle(color: primaryText, fontWeight: FontWeight.w600, fontSize: 16),
      bodyLarge: TextStyle(color: primaryText, fontSize: 16),
      bodyMedium: TextStyle(color: secondaryText, fontSize: 14),
      labelLarge: TextStyle(color: primaryText, fontWeight: FontWeight.w600, fontSize: 14),
    );
  }
}
