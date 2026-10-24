import '../../domain/repositories/ai_response_service.dart';
import '../../domain/usecases/local_response_engine.dart';

class SimulatedAiResponseService implements AiResponseService {
  const SimulatedAiResponseService();
  @override
  Future<String> getResponse(
    String question, {
    List<Map<String, String>> history = const [],
  }) async => const LocalResponseEngine().respond(question);
}
