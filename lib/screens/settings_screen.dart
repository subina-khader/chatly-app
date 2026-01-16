import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/settings_provider.dart';
import '../config/app_config.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final TextEditingController _apiKeyController = TextEditingController();
  bool _obscureApiKey = true;

  @override
  void initState() {
    super.initState();
    final settings = ref.read(settingsProvider);
    _apiKeyController.text = settings.apiKey ?? '';
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          // API Provider
          ListTile(
            title: const Text('AI Provider'),
            subtitle: Text(settings.provider == AIProvider.openai
                ? 'OpenAI (ChatGPT)'
                : 'Google Gemini'),
          ),
          RadioListTile<AIProvider>(
            title: const Text('OpenAI (ChatGPT)'),
            value: AIProvider.openai,
            groupValue: settings.provider,
            onChanged: (value) {
              if (value != null) {
                ref.read(settingsProvider.notifier).setProvider(value);
              }
            },
          ),
          RadioListTile<AIProvider>(
            title: const Text('Google Gemini'),
            value: AIProvider.gemini,
            groupValue: settings.provider,
            onChanged: (value) {
              if (value != null) {
                ref.read(settingsProvider.notifier).setProvider(value);
              }
            },
          ),

          const Divider(),

          // API Key
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'API Key',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _apiKeyController,
                  obscureText: _obscureApiKey,
                  decoration: InputDecoration(
                    hintText: 'Enter your API key',
                    border: const OutlineInputBorder(),
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            _obscureApiKey ? Icons.visibility : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() => _obscureApiKey = !_obscureApiKey);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.save),
                          onPressed: () {
                            ref.read(settingsProvider.notifier)
                                .setApiKey(_apiKeyController.text);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('API key saved')),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  settings.provider == AIProvider.openai
                      ? 'Get your API key from platform.openai.com'
                      : 'Get your API key from makersuite.google.com',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),

          const Divider(),

          // Features
          SwitchListTile(
            title: const Text('Text-to-Speech'),
            subtitle: const Text('Read AI responses aloud'),
            value: settings.ttsEnabled,
            onChanged: (value) {
              ref.read(settingsProvider.notifier).setTtsEnabled(value);
            },
          ),
          SwitchListTile(
            title: const Text('Auto-save Chats'),
            subtitle: const Text('Automatically save chat history'),
            value: settings.autoSave,
            onChanged: (value) {
              ref.read(settingsProvider.notifier).setAutoSave(value);
            },
          ),

          const Divider(),

          // About
          ListTile(
            title: const Text('About'),
            subtitle: const Text('AI Chat Assistant v1.0.0'),
          ),
        ],
      ),
    );
  }
}