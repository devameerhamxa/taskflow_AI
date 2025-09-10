import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:taskflow_ai/core/services/safe_dotenv.dart';

// This class will be a singleton to hold our app configuration.
class ConfigService {
  // Private constructor
  ConfigService._();

  // The single instance of the class
  static final instance = ConfigService._();

  String? _geminiApiKey;

  // A getter to safely access the API key.
  String get geminiApiKey {
    if (_geminiApiKey == null) {
      throw Exception(
        'ConfigService not initialized or GEMINI_API_KEY is missing!',
      );
    }
    return _geminiApiKey!;
  }

  // A method to load the .env file.
  Future<void> initialize() async {
    await SafeDotEnv.load(fileName: ".env");
    _geminiApiKey = dotenv.env['GEMINI_API_KEY'];
  }
}
