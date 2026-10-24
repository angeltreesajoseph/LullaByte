import 'package:flutter_test/flutter_test.dart';
import 'package:lullabyte/core/auth/login_error_message.dart';

void main() {
  test('wrong password and Firebase credential errors have clear wording', () {
    for (final code in [
      'wrong-password', 'invalid-credential', 'invalid-login-credentials',
    ]) {
      expect(loginErrorMessage(code), 'Wrong password. Please try again.');
    }
  });

  test('network and rate-limit failures are not reported as wrong password', () {
    expect(loginErrorMessage('network-request-failed'), contains('internet'));
    expect(loginErrorMessage('too-many-requests'), contains('Too many attempts'));
    expect(loginErrorMessage('unknown'), 'Could not sign in. Please try again.');
  });
}
