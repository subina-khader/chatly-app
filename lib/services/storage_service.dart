import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/message.dart';
import '../models/chat_session.dart';
import '../config/app_config.dart'; // Add this import


final storageServiceProvider = Provider<StorageService>((ref) => StorageService());

class StorageService {
  static const String _messagesKey = 'chat_messages';
  static const String _sessionsKey = 'chat_sessions';
  static const String _currentSessionKey = 'current_session_id';
  static const String _apiKeyKey = 'api_key';
  static const String _apiProviderKey = 'api_provider';

  // Save messages for a session
  Future<void> saveMessages(String sessionId, List<ChatMessage> messages) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '${_messagesKey}_$sessionId';
    final jsonList = messages.map((m) => m.toJson()).toList();
    await prefs.setString(key, jsonEncode(jsonList));
  }

  // Load messages for a session
  Future<List<ChatMessage>> loadMessages(String sessionId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '${_messagesKey}_$sessionId';
    final jsonString = prefs.getString(key);
    if (jsonString == null) return [];

    final List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList.map((json) => ChatMessage.fromJson(json)).toList();
  }

  // Save chat sessions
  Future<void> saveSessions(List<ChatSession> sessions) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = sessions.map((s) => s.toJson()).toList();
    await prefs.setString(_sessionsKey, jsonEncode(jsonList));
  }

  // Load chat sessions
  Future<List<ChatSession>> loadSessions() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_sessionsKey);
    if (jsonString == null) return [];

    final List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList.map((json) => ChatSession.fromJson(json)).toList();
  }

  // Current session management
  Future<void> setCurrentSession(String sessionId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currentSessionKey, sessionId);
  }

  Future<String?> getCurrentSession() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_currentSessionKey);
  }

  // API Key management
  Future<void> saveApiKey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_apiKeyKey, key);
  }

  Future<String?> getApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_apiKeyKey);
  }

  // API Provider management
  Future<void> saveApiProvider(AIProvider provider) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_apiProviderKey, provider.name);
  }

  Future<AIProvider> getApiProvider() async {
    final prefs = await SharedPreferences.getInstance();
    final providerName = prefs.getString(_apiProviderKey);
    return AIProvider.values.firstWhere(
          (e) => e.name == providerName,
      orElse: () => AIProvider.openai,
    );
  }

  // Delete session
  Future<void> deleteSession(String sessionId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('${_messagesKey}_$sessionId');
  }

  // Clear all data
  Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
