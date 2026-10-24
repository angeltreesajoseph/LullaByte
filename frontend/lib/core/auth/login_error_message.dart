/// Friendly login errors without exposing raw Firebase messages.
String loginErrorMessage(String code) => switch (code) {
  'wrong-password' || 'invalid-credential' || 'invalid-login-credentials' =>
    'Wrong password. Please try again.',
  'network-request-failed' =>
    'Could not connect. Check your internet connection and try again.',
  'too-many-requests' => 'Too many attempts. Please try again later.',
  'user-disabled' => 'This account is disabled. Please contact support.',
  'user-not-found' || 'invalid-email' =>
    'Check your email and password. Please try again.',
  _ => 'Could not sign in. Please try again.',
};
