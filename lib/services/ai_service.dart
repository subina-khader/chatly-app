import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/message.dart';

final aiServiceProvider = Provider<AIService>((ref) => AIService());

class AIService {
  String? _apiKey;
  AIProvider _provider = AIProvider.openai;

  void configure(String apiKey, AIProvider provider) {
    _apiKey = apiKey;
    _provider = provider;
  }

  // Stream responses from AI
  Stream<String> sendMessageStream(
      String message, {
        List<ChatMessage>? history,
        String? imageBase64,
      }) async* {
    if (_apiKey == null || _apiKey!.isEmpty) {
      throw Exception('API key not configured');
    }

    if (_provider == AIProvider.openai) {
      yield* _sendOpenAIStream(message, history: history, imageBase64: imageBase64);
    } else {
      yield* _sendGeminiStream(message, history: history, imageBase64: imageBase64);
    }
  }

  // OpenAI Streaming
  Stream<String> _sendOpenAIStream(
      String message, {
        List<ChatMessage>? history,
        String? imageBase64,
      }) async* {
    final url = Uri.parse('${AppConfig.openAIBaseUrl}/chat/completions');

    final messages = [
      if (history != null)
        ...history.take(20).map((msg) => {
          'role': msg.isUser ? 'user' : 'assistant',
          'content': msg.text,
        }),
      {
        'role': 'user',
        'content': imageBase64 != null
            ? [
          {'type': 'text', 'text': message},
          {
            'type': 'image_url',
            'image_url': {'url': 'data:image/jpeg;base64,$imageBase64'}
          }
        ]
            : message,
      }
    ];

    final request = http.Request('POST', url)
      ..headers.addAll({
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_apiKey',
      })
      ..body = jsonEncode({
        'model': AppConfig.openAIModel,
        'stream': true,
        'messages': messages,
        'max_tokens': 1000,
      });

    try {
      final response = await request.send().timeout(AppConfig.streamTimeout);

      if (response.statusCode != 200) {
        throw Exception('API Error: ${response.statusCode}');
      }

      await for (var line in response.stream
          .transform(utf8.decoder)
          .transform(const LineSplitter())) {
        if (line.startsWith('data:')) {
          final jsonStr = line.replaceFirst('data:', '').trim();
          if (jsonStr == '[DONE]') break;

          try {
            final data = jsonDecode(jsonStr);
            final delta = data['choices']?[0]?['delta']?['content'];
            if (delta != null) yield delta as String;
          } catch (_) {}
        }
      }
    } catch (e) {
      throw Exception('Stream error: $e');
    }
  }

  // Gemini Streaming
  Stream<String> _sendGeminiStream(
      String message, {
        List<ChatMessage>? history,
        String? imageBase64,
      }) async* {
    final url = Uri.parse(
      '${AppConfig.geminiBaseUrl}/models/${AppConfig.geminiModel}:streamGenerateContent?key=$_apiKey',
    );

    final contents = [
      if (history != null)
        ...history.take(20).map((msg) => {
          'role': msg.isUser ? 'user' : 'model',
          'parts': [
            {'text': msg.text}
          ],
        }),
      {
        'role': 'user',
        'parts': [
          {'text': message},
          if (imageBase64 != null)
            {
              'inline_data': {
                'mime_type': 'image/jpeg',
                'data': imageBase64,
              }
            }
        ],
      }
    ];

    final request = http.Request('POST', url)
      ..headers.addAll({'Content-Type': 'application/json'})
      ..body = jsonEncode({'contents': contents});

    try {
      final response = await request.send().timeout(AppConfig.streamTimeout);

      if (response.statusCode != 200) {
        throw Exception('API Error: ${response.statusCode}');
      }

      await for (var line in response.stream
          .transform(utf8.decoder)
          .transform(const LineSplitter())) {
        if (line.trim().isEmpty || line == '[{' || line == '}]') continue;

        try {
          // Remove trailing comma if present
          final cleanLine = line.endsWith(',') ? line.substring(0, line.length - 1) : line;
          final data = jsonDecode(cleanLine);
          final text = data['candidates']?[0]?['content']?['parts']?[0]?['text'];
          if (text != null) yield text as String;
        } catch (_) {}
      }
    } catch (e) {
      throw Exception('Stream error: $e');
    }
  }
}