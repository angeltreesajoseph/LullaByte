/// Keys used with [SharedPreferences] (non-sensitive local preferences) and
/// [FlutterSecureStorage] (sensitive values such as auth tokens).
///
/// Centralized here so no key string is ever duplicated/mistyped across
/// features (SAD Section 12.5, Secure Storage).
class StorageKeys {
  const StorageKeys._();

  // SharedPreferences (non-sensitive)
  static const String themeMode = 'app.theme_mode';
  static const String hasSeenOnboarding = 'app.has_seen_onboarding';
  static const String localeCode = 'app.locale_code';

  // FlutterSecureStorage (sensitive — reserved for the Authentication
  // feature; not written to by the application foundation).
  static const String accessToken = 'secure.access_token';
  static const String refreshToken = 'secure.refresh_token';
  static const String sqliteEncryptionKey = 'secure.sqlite_encryption_key';
}
