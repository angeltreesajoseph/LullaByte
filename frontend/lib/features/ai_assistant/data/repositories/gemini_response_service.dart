import 'package:dio/dio.dart';
import '../../../baby_management/application/baby_profile_store.dart';
import '../../../family_sharing/application/shared_care_connection.dart';
import '../../domain/repositories/ai_response_service.dart';

class GeminiResponseService implements AiResponseService {
  const GeminiResponseService({this.api});
  final Dio? api;
  @override
  Future<String> getResponse(
    String question, {
    List<Map<String, String>> history = const [],
  }) async {
    final id = BabyProfileStore.id;
    if (id == null) throw StateError('Select a baby profile first.');
    final client = api ?? await sharedCareClient();
    final response = await client.post(
      '/babies/$id/assistant',
      data: {'question': question, 'history': history, 'consent': true},
      options: Options(receiveTimeout: const Duration(seconds: 50)),
    );
    final answer = response.data['data']['answer'];
    if (answer is! String || answer.trim().isEmpty)
      throw StateError('No response.');
    return answer;
  }
}
