import 'dart:convert';
import 'dart:developer'; // Import developer for log
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:taskflow_ai/features/ai_tools/domain/ai_repository.dart';
import 'package:taskflow_ai/features/ai_tools/domain/parsed_task_data_model.dart';

class GeminiAIRepository implements AIRepository {
  static const String _model = 'gemini-1.5-flash-latest';
  final String _apiKey;

  GeminiAIRepository() : _apiKey = dotenv.env['GEMINI_API_KEY'] ?? '' {
    if (_apiKey.isEmpty) {
      throw Exception('GEMINI_API_KEY not found in .env file');
    }
  }

  @override
  Future<ParsedTaskData> parseTextToTask(String text) async {
    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/$_model:generateContent?key=$_apiKey',
    );

    final prompt =
        """
      You are a task parsing assistant. Analyze the following text and extract the task title, due date, and priority.
      The current date is ${DateTime.now().toIso8601String()}.
      Respond ONLY with a valid JSON object with the keys "title", "dueDate" (in ISO 8601 format), and "priority" (as "low", "medium", or "high").
      If any information is missing, use a sensible default. For example, if no date is mentioned, default to tomorrow. If no priority is mentioned, default to medium.

      Text: "$text"

      JSON:
    """;

    // --- FORCE LOGGING START ---
    log('Attempting to call Gemini API...');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt},
              ],
            },
          ],
        }),
      );

      log('API Response Status Code: ${response.statusCode}');
      log('API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final jsonString = body['candidates'][0]['content']['parts'][0]['text'];
        final jsonMap = jsonDecode(jsonString);
        log('Successfully parsed API response.');
        return ParsedTaskData.fromJson(jsonMap);
      } else {
        throw Exception('API returned error: ${response.body}');
      }
    } catch (e) {
      // This will now definitely print to your console.
      log('!!! CRITICAL ERROR in GeminiAIRepository !!!', error: e);
      rethrow; // Re-throw the error to be handled by the controller.
    }
    // --- FORCE LOGGING END ---
  }
}
