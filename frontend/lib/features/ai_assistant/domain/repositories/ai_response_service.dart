/// Contract for the "Online AI" response path.
///
/// The real implementation calls our authenticated Gemini backend proxy.
/// Only explicit online conversation turns may be included as history.
abstract class AiResponseService {
  Future<String> getResponse(
    String question, {
    List<Map<String, String>> history = const [],
  });
}
