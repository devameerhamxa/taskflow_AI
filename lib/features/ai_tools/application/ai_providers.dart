import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskflow_ai/core/services/config_service.dart';
import 'package:taskflow_ai/features/ai_tools/domain/ai_repository.dart';
import 'package:taskflow_ai/features/ai_tools/domain/parsed_task_data_model.dart';
import 'package:taskflow_ai/features/ai_tools/infrastructure/gemini_ai_repository.dart';

// Repository Provider
final aiRepositoryProvider = Provider<AIRepository>((ref) {
  final apiKey = ConfigService.instance.geminiApiKey;
  return GeminiAIRepository(apiKey: apiKey);
});

// AI Controller Provider
final aiControllerProvider = StateNotifierProvider<AIController, bool>((ref) {
  final aiRepository = ref.watch(aiRepositoryProvider);
  return AIController(aiRepository: aiRepository);
});

class AIController extends StateNotifier<bool> {
  final AIRepository _aiRepository;

  AIController({required AIRepository aiRepository})
    : _aiRepository = aiRepository,
      super(false); // State represents loading status

  Future<ParsedTaskData?> parseTextToTask({
    required String text,
    required Function(String) onError,
  }) async {
    state = true;
    ParsedTaskData? parsedData;
    try {
      parsedData = await _aiRepository.parseTextToTask(text);
    } catch (e) {
      onError(e.toString());
    } finally {
      // Ensure the loading state is always reset.
      state = false;
    }
    return parsedData;
  }
}
