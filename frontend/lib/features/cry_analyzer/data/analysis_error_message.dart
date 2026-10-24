/// Decode the backend's standard error envelope without exposing raw responses.
String cryAnalysisErrorMessage(Object? payload, int? status) {
  if (payload is Map) {
    final error = payload['error'];
    if (error is Map && error['message'] is String) {
      return error['message'] as String;
    }
    if (payload['detail'] is String) return payload['detail'] as String;
  }
  if (status == 401) return 'Please sign in again before analyzing audio.';
  if (status == 404) return 'The analyzer endpoint is not deployed yet.';
  if (status == 502 || status == 503 || status == 504) {
    return 'The analyzer server is unavailable (HTTP $status). Retry shortly or check Render logs.';
  }
  return status == null
      ? 'No response from the analyzer. Check your connection and retry.'
      : 'Analysis failed (HTTP $status). Please retry or check Render logs.';
}
