import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/chat_provider.dart';
import '../providers/settings_provider.dart';
import '../services/speech_service.dart';
import '../services/image_service.dart';
import '../widgets/message_bubble.dart';
import '../widgets/chat_input.dart';
import 'settings_screen.dart';
import 'history_screen.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isListening = false;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _handleMicTap() async {
    final speechService = ref.read(speechServiceProvider);

    if (_isListening) {
      await speechService.stopListening();
      setState(() => _isListening = false);
    } else {
      try {
        await speechService.startListening((text) {
          if (text.isNotEmpty) {
            ref.read(chatProvider.notifier).sendMessage(text);
            setState(() => _isListening = false);
          }
        });
        setState(() => _isListening = true);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Voice input error: $e')),
        );
      }
    }
  }

  Future<void> _handleImageTap() async {
    final imageService = ref.read(imageServiceProvider);

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Image'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () async {
                final base64 = await imageService.pickImageFromGallery();
                if (context.mounted) Navigator.pop(context, base64);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Photo'),
              onTap: () async {
                final base64 = await imageService.takePhoto();
                if (context.mounted) Navigator.pop(context, base64);
              },
            ),
          ],
        ),
      ),
    );

    if (result != null) {
      // Show dialog to add description
      final controller = TextEditingController();
      final description = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Describe the image'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: 'What would you like to know about this image?',
            ),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, controller.text),
              child: const Text('Send'),
            ),
          ],
        ),
      );

      if (description != null && description.isNotEmpty) {
        ref.read(chatProvider.notifier).sendMessage(
          description,
          imageBase64: result,
        );
        _scrollToBottom();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatProvider);
    final settings = ref.watch(settingsProvider);

    // Scroll to bottom when messages change
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (chatState.messages.isNotEmpty) _scrollToBottom();
    });

    // Show API key setup if not configured
    if (settings.apiKey == null || settings.apiKey!.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('AI Chat Assistant')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.settings, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              const Text(
                'Please configure your API key',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Icons.settings),
                label: const Text('Go to Settings'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SettingsScreen()),
                  );
                },
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Chat Assistant'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HistoryScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              ref.read(chatProvider.notifier).createNewSession();
            },
            tooltip: 'New Chat',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Error banner
          if (chatState.error != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: Colors.red.shade100,
              child: Row(
                children: [
                  const Icon(Icons.error, color: Colors.red),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      chatState.error!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),

          // Messages list
          Expanded(
            child: chatState.messages.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Start a conversation',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            )
                : ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.only(bottom: 16),
              itemCount: chatState.messages.length,
              itemBuilder: (context, index) {
                final message = chatState.messages[index];
                return MessageBubble(
                  message: message,
                  onSpeak: () {
                    ref.read(speechServiceProvider).speak(message.text);
                  },
                );
              },
            ),
          ),

          // Input area
          ChatInput(
            onSend: (text) {
              ref.read(chatProvider.notifier).sendMessage(text);
            },
            onMicTap: _handleMicTap,
            onImageTap: _handleImageTap,
            isListening: _isListening,
            isLoading: chatState.isLoading,
          ),
        ],
      ),
    );
  }
}
