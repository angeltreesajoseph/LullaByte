/// App-wide, non-environment-specific constants shared across features.
class AppConstants {
  const AppConstants._();

  static const String appName = 'LullaByte';
  static const String appTagline = 'AI Powered Newborn Care Assistant';

  // Spacing / layout — used by the reusable widgets in lib/widgets/.
  static const double spacingXs = 4;
  static const double spacingSm = 8;
  static const double spacingMd = 16;
  static const double spacingLg = 24;
  static const double spacingXl = 32;

  static const double radiusMd = 16;
  static const double radiusLg = 24;

  // Minimum accessible tap target size (SRS Section 15.4, Large Buttons).
  static const double minTapTarget = 48;

  static const Duration snackBarDuration = Duration(seconds: 3);
  static const Duration defaultAnimationDuration = Duration(milliseconds: 250);
}
