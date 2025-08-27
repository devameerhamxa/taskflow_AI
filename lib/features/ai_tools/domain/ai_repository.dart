import 'package:taskflow_ai/features/ai_tools/domain/parsed_task_data_model.dart';

abstract class AIRepository {
  /// Sends a text prompt to the AI model to parse it into structured task data.
  Future<ParsedTaskData> parseTextToTask(String text);
}
