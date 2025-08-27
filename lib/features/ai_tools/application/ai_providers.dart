import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskflow_ai/features/ai_tools/domain/ai_repository.dart';
import 'package:taskflow_ai/features/ai_tools/domain/parsed_task_data_model.dart';
import 'package:taskflow_ai/features/ai_tools/infrastructure/gemini_ai_repository.dart';

// 1. Repository Provider
final aiRepositoryProvider = Provider<AIRepository>((ref) {
  return GeminiAIRepository();
});

// 2. AI Controller Provider
final aiControllerProvider = StateNotifierProvider<AIController, bool>((ref) {
  final aiRepository = ref.watch(aiRepositoryProvider);
  return AIController(aiRepository: aiRepository);
});

class AIController extends StateNotifier<bool> {
  final AIRepository _aiRepository;

  AIController({required AIRepository aiRepository})
    : _aiRepository = aiRepository,
      super(false); // State represents loading status

  // --- THIS IS THE CRITICAL CHANGE ---
  // The method now returns the parsed data on success and calls an onError
  // callback on failure, preventing the app from freezing.
  Future<ParsedTaskData?> parseTextToTask({
    required String text,
    required Function(String) onError,
  }) async {
    state = true;
    ParsedTaskData? parsedData;
    try {
      parsedData = await _aiRepository.parseTextToTask(text);
    } catch (e) {
      // If an error occurs, call the onError callback with the message.
      onError(e.toString());
    } finally {
      // Ensure the loading state is always reset.
      state = false;
    }
    return parsedData;
  }

  // --- END OF CHANGE ---
}
