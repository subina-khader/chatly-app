import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/storage_service.dart';
import '../config/app_config.dart';

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier(ref.read(storageServiceProvider));
});

class SettingsState {
  final String? apiKey;
  final AIProvider provider;
  final bool ttsEnabled;
  final bool autoSave;

  SettingsState({
    this.apiKey,
    this.provider = AIProvider.openai,
    this.ttsEnabled = false,
    this.autoSave = true,
  });

  SettingsState copyWith({
    String? apiKey,
    AIProvider? provider,
    bool? ttsEnabled,
    bool? autoSave,
  }) {
    return SettingsState(
      apiKey: apiKey ?? this.apiKey,
      provider: provider ?? this.provider,
      ttsEnabled: ttsEnabled ?? this.ttsEnabled,
      autoSave: autoSave ?? this.autoSave,
    );
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier(this._storage) : super(SettingsState()) {
    _loadSettings();
  }

  final StorageService _storage;

  Future<void> _loadSettings() async {
    final apiKey = await _storage.getApiKey();
    final provider = await _storage.getApiProvider();
    state = state.copyWith(apiKey: apiKey, provider: provider);
  }

  Future<void> setApiKey(String key) async {
    await _storage.saveApiKey(key);
    state = state.copyWith(apiKey: key);
  }

  Future<void> setProvider(AIProvider provider) async {
    await _storage.saveApiProvider(provider);
    state = state.copyWith(provider: provider);
  }

  void setTtsEnabled(bool enabled) {
    state = state.copyWith(ttsEnabled: enabled);
  }

  void setAutoSave(bool enabled) {
    state = state.copyWith(autoSave: enabled);
  }
}