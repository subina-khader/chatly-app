import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/message.dart';
import '../models/chat_session.dart';
import '../services/ai_service.dart';
import '../services/storage_service.dart';
import '../services/speech_service.dart';
import 'settings_provider.dart';

final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  return ChatNotifier(
    ref.read(aiServiceProvider),
    ref.read(storageServiceProvider),
    ref.read(speechServiceProvider),
    ref.watch(settingsProvider),
  );
});

class ChatState {
  final List<ChatMessage> messages;
  final List<ChatSession> sessions;
  final String? currentSessionId;
  final bool isLoading;
  final String? error;
  final bool isSpeaking;

  ChatState({
    this.messages = const [],
    this.sessions = const [],
    this.currentSessionId,
    this.isLoading = false,
    this.error,
    this.isSpeaking = false,
  });

  ChatState copyWith({
    List<ChatMessage>? messages,
    List<ChatSession>? sessions,
    String? currentSessionId,
    bool? isLoading,
    String? error,
    bool? isSpeaking,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      sessions: sessions ?? this.sessions,
      currentSessionId: currentSessionId ?? this.currentSessionId,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isSpeaking: isSpeaking ?? this.isSpeaking,
    );
  }
}

class ChatNotifier extends StateNotifier<ChatState> {
  ChatNotifier(
      this._aiService,
      this._storage,
      this._speechService,
      this._settings,
      ) : super(ChatState()) {
    _initialize();
  }

  final AIService _aiService;
  final StorageService _storage;
  final SpeechService _speechService;
  final SettingsState _settings;

  Future<void> _initialize() async {
    // Load sessions
    final sessions = await _storage.loadSessions();
    final currentSessionId = await _storage.getCurrentSession();

    // Load current session messages
    List<ChatMessage> messages = [];
    if (currentSessionId != null) {
      messages = await _storage.loadMessages(currentSessionId);
    } else if (sessions.isNotEmpty) {
      messages = await _storage.loadMessages(sessions.first.id);
    }

    state = state.copyWith(
      sessions: sessions,
      currentSessionId: currentSessionId ?? sessions.firstOrNull?.id,
      messages: messages,
    );

    // Configure AI service
    if (_settings.apiKey != null) {
      _aiService.configure(_settings.apiKey!, _settings.provider);
    }
  }

  // Send message
  Future<void> sendMessage(String userMsg, {String? imageBase64}) async {
    if (userMsg.trim().isEmpty && imageBase64 == null) return;

    // Ensure we have a session
    if (state.currentSessionId == null) {
      await createNewSession();
    }

    final userMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: userMsg,
      isUser: true,
      timestamp: DateTime.now(),
      imageBase64: imageBase64,
    );

    state = state.copyWith(
      messages: [...state.messages, userMessage],
      isLoading: true,
      error: null,
    );

    try {
      final stream = _aiService.sendMessageStream(
        userMsg,
        history: state.messages,
        imageBase64: imageBase64,
      );

      String buffer = '';
      await for (var chunk in stream) {
        buffer += chunk;
        _updateAIMessage(buffer);
      }

      // Save messages
      if (_settings.autoSave) {
        await _saveCurrentSession();
      }

      state = state.copyWith(isLoading: false);

      // Speak response if TTS enabled
      if (_settings.ttsEnabled && buffer.isNotEmpty) {
        await _speechService.speak(buffer);
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to get response: ${e.toString()}',
      );

      // Mark last message as error
      if (state.messages.isNotEmpty && !state.messages.last.isUser) {
        final updatedMessages = [...state.messages];
        updatedMessages[updatedMessages.length - 1] =
            updatedMessages.last.copyWith(status: MessageStatus.error);
        state = state.copyWith(messages: updatedMessages);
      }
    }
  }

  void _updateAIMessage(String text) {
    final messages = [...state.messages];

    if (messages.isNotEmpty && !messages.last.isUser) {
      messages[messages.length - 1] = messages.last.copyWith(text: text);
    } else {
      messages.add(ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: text,
        isUser: false,
        timestamp: DateTime.now(),
      ));
    }

    state = state.copyWith(messages: messages);
  }

  // Session management
  Future<void> createNewSession() async {
    final session = ChatSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'New Chat',
      createdAt: DateTime.now(),
      lastMessageAt: DateTime.now(),
    );

    final sessions = [session, ...state.sessions];
    await _storage.saveSessions(sessions);
    await _storage.setCurrentSession(session.id);

    state = state.copyWith(
      sessions: sessions,
      currentSessionId: session.id,
      messages: [],
    );
  }

  Future<void> switchSession(String sessionId) async {
    final messages = await _storage.loadMessages(sessionId);
    await _storage.setCurrentSession(sessionId);

    state = state.copyWith(
      currentSessionId: sessionId,
      messages: messages,
    );
  }

  Future<void> deleteSession(String sessionId) async {
    await _storage.deleteSession(sessionId);

    final sessions = state.sessions.where((s) => s.id != sessionId).toList();
    await _storage.saveSessions(sessions);

    if (state.currentSessionId == sessionId) {
      if (sessions.isNotEmpty) {
        await switchSession(sessions.first.id);
      } else {
        await createNewSession();
      }
    } else {
      state = state.copyWith(sessions: sessions);
    }
  }

  Future<void> _saveCurrentSession() async {
    if (state.currentSessionId == null) return;

    await _storage.saveMessages(state.currentSessionId!, state.messages);

    // Update session title and timestamp
    final sessions = [...state.sessions];
    final index = sessions.indexWhere((s) => s.id == state.currentSessionId);

    if (index != -1) {
      final session = sessions[index];
      final title = state.messages.isNotEmpty
          ? state.messages.first.text.length > 30
          ? '${state.messages.first.text.substring(0, 30)}...'
          : state.messages.first.text
          : 'New Chat';

      sessions[index] = ChatSession(
        id: session.id,
        title: title,
        createdAt: session.createdAt,
        lastMessageAt: DateTime.now(),
      );

      await _storage.saveSessions(sessions);
      state = state.copyWith(sessions: sessions);
    }
  }

  // Clear current chat
  void clearChat() {
    state = state.copyWith(messages: []);
  }

  // Speech control
  Future<void> toggleSpeech() async {
    if (state.isSpeaking) {
      await _speechService.stopSpeaking();
      state = state.copyWith(isSpeaking: false);
    }
  }
}