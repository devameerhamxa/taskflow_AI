import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SafeDotEnv {
  static Future<void> load({String fileName = ".env"}) async {
    try {
      final content = await rootBundle.loadString(fileName);
      if (content.trim().isEmpty) {
        throw Exception("Dotenv file is empty: $fileName");
      }
      await dotenv.load(fileName: fileName);
    } catch (e) {
      throw Exception("Failed to load $fileName: $e");
    }
  }
}
