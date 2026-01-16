class AppConfig {
  // API Configuration
  static const String openAIBaseUrl = 'https://api.openai.com/v1';
  static const String geminiBaseUrl = 'https://generativelanguage.googleapis.com/v1beta';

  // Model Configuration
  static const String openAIModel = 'gpt-4o-mini';
  static const String geminiModel = 'gemini-1.5-flash';

  // App Settings
  static const int maxMessageLength = 4000;
  static const int maxHistoryMessages = 100;
  static const Duration streamTimeout = Duration(seconds: 60);
}

enum AIProvider { openai, gemini }
