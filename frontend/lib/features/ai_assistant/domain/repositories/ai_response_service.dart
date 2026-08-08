/// Contract for the "Online AI" response path.
///
/// [SimulatedAiResponseService] (`data/repositories/`) is the only
/// implementation today. When a real model is wired up, a new
/// implementation — e.g. `GeminiResponseService` or `OpenAiResponseService`
/// — should implement this same single method and be bound in place of
/// [SimulatedAiResponseService] in `aiResponseServiceProvider`
/// (`application/assistant_providers.dart`). No other file in this feature
/// needs to change.
abstract class AiResponseService {
  Future<String> getResponse(String question);
}
