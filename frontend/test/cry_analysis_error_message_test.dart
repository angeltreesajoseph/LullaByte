import 'package:flutter_test/flutter_test.dart';
import 'package:lullabyte/features/cry_analyzer/data/analysis_error_message.dart';

void main() {
  test('standard error envelope exposes the real inference failure', () {
    expect(
      cryAnalysisErrorMessage({
        'error': {
          'message': 'Experimental model unavailable. Check server setup.',
        },
      }, 503),
      'Experimental model unavailable. Check server setup.',
    );
  });
  test('legacy detail and gateway responses are readable', () {
    expect(
      cryAnalysisErrorMessage({'detail': 'Silent audio'}, 422),
      'Silent audio',
    );
    expect(
      cryAnalysisErrorMessage('<html>gateway failure</html>', 502),
      contains('HTTP 502'),
    );
  });
  test('no response and authentication failures are distinct', () {
    expect(cryAnalysisErrorMessage(null, null), contains('No response'));
    expect(cryAnalysisErrorMessage(null, 401), contains('sign in'));
  });
}
