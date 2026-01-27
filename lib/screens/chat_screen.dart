// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../providers/chat_provider.dart';
// import '../providers/settings_provider.dart';
// import '../services/speech_service.dart';
// import '../services/image_service.dart';
// import '../widgets/message_bubble.dart';
// import '../widgets/chat_input.dart';
// import 'settings_screen.dart';
// import 'history_screen.dart';
//
// class ChatScreen extends ConsumerStatefulWidget {
//   const ChatScreen({super.key});
//
//   @override
//   ConsumerState<ChatScreen> createState() => _ChatScreenState();
// }
//
// class _ChatScreenState extends ConsumerState<ChatScreen> {
//   final ScrollController _scrollController = ScrollController();
//   bool _isListening = false;
//
//   @override
//   void dispose() {
//     _scrollController.dispose();
//     super.dispose();
//   }
//
//   void _scrollToBottom() {
//     if (_scrollController.hasClients) {
//       _scrollController.animateTo(
//         _scrollController.position.maxScrollExtent,
//         duration: const Duration(milliseconds: 300),
//         curve: Curves.easeOut,
//       );
//     }
//   }
//
//   Future<void> _handleMicTap() async {
//     final speechService = ref.read(speechServiceProvider);
//
//     if (_isListening) {
//       await speechService.stopListening();
//       setState(() => _isListening = false);
//     } else {
//       try {
//         await speechService.startListening((text) {
//           if (text.isNotEmpty) {
//             ref.read(chatProvider.notifier).sendMessage(text);
//             setState(() => _isListening = false);
//           }
//         });
//         setState(() => _isListening = true);
//       } catch (e) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Voice input error: $e')),
//         );
//       }
//     }
//   }
//
//   Future<void> _handleImageTap() async {
//     final imageService = ref.read(imageServiceProvider);
//
//     final result = await showDialog<String>(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Add Image'),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             ListTile(
//               leading: const Icon(Icons.photo_library),
//               title: const Text('Choose from Gallery'),
//               onTap: () async {
//                 final base64 = await imageService.pickImageFromGallery();
//                 if (context.mounted) Navigator.pop(context, base64);
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.camera_alt),
//               title: const Text('Take Photo'),
//               onTap: () async {
//                 final base64 = await imageService.takePhoto();
//                 if (context.mounted) Navigator.pop(context, base64);
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//
//     if (result != null) {
//       // Show dialog to add description
//       final controller = TextEditingController();
//       final description = await showDialog<String>(
//         context: context,
//         builder: (context) => AlertDialog(
//           title: const Text('Describe the image'),
//           content: TextField(
//             controller: controller,
//             decoration: const InputDecoration(
//               hintText: 'What would you like to know about this image?',
//             ),
//             maxLines: 3,
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text('Cancel'),
//             ),
//             TextButton(
//               onPressed: () => Navigator.pop(context, controller.text),
//               child: const Text('Send'),
//             ),
//           ],
//         ),
//       );
//
//       if (description != null && description.isNotEmpty) {
//         ref.read(chatProvider.notifier).sendMessage(
//           description,
//           imageBase64: result,
//         );
//         _scrollToBottom();
//       }
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final chatState = ref.watch(chatProvider);
//     final settings = ref.watch(settingsProvider);
//
//     // Scroll to bottom when messages change
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (chatState.messages.isNotEmpty) _scrollToBottom();
//     });
//
//     // Show API key setup if not configured
//     if (settings.apiKey == null || settings.apiKey!.isEmpty) {
//       return Scaffold(
//         appBar: AppBar(title: const Text('AI Chat Assistant')),
//         body: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               const Icon(Icons.settings, size: 64, color: Colors.grey),
//               const SizedBox(height: 16),
//               const Text(
//                 'Please configure your API key',
//                 style: TextStyle(fontSize: 18),
//               ),
//               const SizedBox(height: 24),
//               ElevatedButton.icon(
//                 icon: const Icon(Icons.settings),
//                 label: const Text('Go to Settings'),
//                 onPressed: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(builder: (_) => const SettingsScreen()),
//                   );
//                 },
//               ),
//             ],
//           ),
//         ),
//       );
//     }
//
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('AI Chat Assistant'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.history),
//             onPressed: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (_) => const HistoryScreen()),
//               );
//             },
//           ),
//           IconButton(
//             icon: const Icon(Icons.add),
//             onPressed: () {
//               ref.read(chatProvider.notifier).createNewSession();
//             },
//             tooltip: 'New Chat',
//           ),
//           IconButton(
//             icon: const Icon(Icons.settings),
//             onPressed: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (_) => const SettingsScreen()),
//               );
//             },
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           // Error banner
//           if (chatState.error != null)
//             Container(
//               width: double.infinity,
//               padding: const EdgeInsets.all(12),
//               color: Colors.red.shade100,
//               child: Row(
//                 children: [
//                   const Icon(Icons.error, color: Colors.red),
//                   const SizedBox(width: 8),
//                   Expanded(
//                     child: Text(
//                       chatState.error!,
//                       style: const TextStyle(color: Colors.red),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//
//           // Messages list
//           Expanded(
//             child: chatState.messages.isEmpty
//                 ? Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(
//                     Icons.chat_bubble_outline,
//                     size: 64,
//                     color: Colors.grey.shade400,
//                   ),
//                   const SizedBox(height: 16),
//                   Text(
//                     'Start a conversation',
//                     style: TextStyle(
//                       fontSize: 18,
//                       color: Colors.grey.shade600,
//                     ),
//                   ),
//                 ],
//               ),
//             )
//                 : ListView.builder(
//               controller: _scrollController,
//               padding: const EdgeInsets.only(bottom: 16),
//               itemCount: chatState.messages.length,
//               itemBuilder: (context, index) {
//                 final message = chatState.messages[index];
//                 return MessageBubble(
//                   message: message,
//                   onSpeak: () {
//                     ref.read(speechServiceProvider).speak(message.text);
//                   },
//                 );
//               },
//             ),
//           ),
//
//           // Input area
//           ChatInput(
//             onSend: (text) {
//               ref.read(chatProvider.notifier).sendMessage(text);
//             },
//             onMicTap: _handleMicTap,
//             onImageTap: _handleImageTap,
//             isListening: _isListening,
//             isLoading: chatState.isLoading,
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/chat_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/workspace_provider.dart';
import '../providers/snippets_provider.dart';
import '../services/speech_service.dart';
import '../services/image_service.dart';
import '../widgets/message_bubble.dart';
import '../widgets/chat_input.dart';
import '../models/snippet.dart';
import 'settings_screen.dart';
import 'history_screen.dart';
import '../services/ai_service.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _chatInputController = TextEditingController();

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
  String _getSelectedText() {
    // Simply return all text from the controller
    return _chatInputController.text;
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

  // Feature 3: Save to Snippets
  void _showSaveToSnippetsDialog(String content, String messageId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Save to Snippets'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: SnippetType.values.map((type) {
            return ListTile(
              leading: Icon(_getSnippetIcon(type)),
              title: Text(type.name.toUpperCase()),
              onTap: () {
                ref.read(snippetsProvider.notifier).addSnippet(
                  content,
                  type,
                  sourceMessageId: messageId,
                );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Saved to Snippets!')),
                );
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  IconData _getSnippetIcon(SnippetType type) {
    switch (type) {
      case SnippetType.text:
        return Icons.text_fields;
      case SnippetType.link:
        return Icons.link;
      case SnippetType.image:
        return Icons.image;
      case SnippetType.audio:
        return Icons.audiotrack;
      case SnippetType.number:
        return Icons.numbers;
      case SnippetType.code:
        return Icons.code;
    }
  }
// Feature 1: Add to Notes
  void _showAddToNotesDialog(String content, String messageId) async {
    // Load folders first
    await ref.read(workspaceProvider.notifier).loadFolders();
    final workspaceState = ref.read(workspaceProvider);

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add to Notes'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (workspaceState.folders.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('No folders yet. Create one in Workspace!'),
                )
              else
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 300),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: workspaceState.folders.length,
                    itemBuilder: (context, index) {
                      final folder = workspaceState.folders[index];
                      return ListTile(
                        leading: const Icon(Icons.folder),
                        title: Text(folder.name),
                        onTap: () {
                          Navigator.pop(context);
                          _showCreateOrSelectNote(folder.id, content, messageId);
                        },
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showCreateOrSelectNote(String folderId, String content, String messageId) async {
    await ref.read(workspaceProvider.notifier).loadNotes(folderId);
    final notes = ref.read(workspaceProvider).notes;

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Note'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Create New Note'),
                  onPressed: () {
                    Navigator.pop(context);
                    _createNewNoteWithContent(folderId, content, messageId);
                  },
                ),
              ),
              if (notes.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text('Or add to existing note:'),
                const SizedBox(height: 8),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 250),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: notes.length,
                    itemBuilder: (context, index) {
                      final note = notes[index];
                      return ListTile(
                        leading: const Icon(Icons.note),
                        title: Text(note.title),
                        onTap: () {
                          _addContentToNote(note, content);
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
  void _showSmartEditMenu() {
    final selectedText = _getSelectedText();
    if (selectedText.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter or select text first')),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Smart Edit',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildSmartEditOption(Icons.check_circle, 'Fix Grammar', 'grammar'),
            _buildSmartEditOption(Icons.refresh, 'Rephrase', 'rephrase'),
            _buildSmartEditOption(Icons.straighten, 'Simplify', 'simplify'),
            _buildSmartEditOption(Icons.business, 'Make Professional', 'professional'),
            _buildSmartEditOption(Icons.expand, 'Expand', 'expand'),
            _buildSmartEditOption(Icons.compress, 'Shorten', 'shorten'),
          ],
        ),
      ),
    );
  }

  Widget _buildSmartEditOption(IconData icon, String label, String action) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      onTap: () async {
        Navigator.pop(context);
        await _performSmartEdit(action);
      },
    );
  }

  Future<void> _performSmartEdit(String action) async {
    final selectedText = _getSelectedText();
    if (selectedText.trim().isEmpty) return;

    final selection = _chatInputController.selection;
    final hasSelection = selection.isValid && selection.start != selection.end;

    final prompts = {
      'grammar': 'Fix all grammar and spelling errors in the following text. Return ONLY the corrected text, no explanations:\n\n$selectedText',
      'rephrase': 'Rephrase the following text to make it clearer while keeping the same meaning. Return ONLY the rephrased text, no explanations:\n\n$selectedText',
      'simplify': 'Simplify the following text to make it easier to understand. Return ONLY the simplified text, no explanations:\n\n$selectedText',
      'professional': 'Rewrite the following text to make it more professional and formal. Return ONLY the professional version, no explanations:\n\n$selectedText',
      'expand': 'Expand the following text with more details and context. Return ONLY the expanded text, no explanations:\n\n$selectedText',
      'shorten': 'Make the following text shorter and more concise. Return ONLY the shortened text, no explanations:\n\n$selectedText',
    };

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Processing...'),
                ],
              ),
            ),
          ),
        ),
      );

      final ai = ref.read(aiServiceProvider);
      final stream = ai.sendMessageStream(prompts[action]!);
      String result = '';

      await for (var chunk in stream) {
        result += chunk;
      }

      if (mounted) {
        Navigator.pop(context); // Close loading dialog

        // Clean up the result (remove any markdown formatting or quotes)
        result = result.trim();
        if (result.startsWith('"') && result.endsWith('"')) {
          result = result.substring(1, result.length - 1);
        }

        if (hasSelection) {
          // Replace only the selected text
          final newText = _chatInputController.text.replaceRange(
            selection.start,
            selection.end,
            result,
          );
          _chatInputController.text = newText;

          // Set cursor at the end of replaced text
          _chatInputController.selection = TextSelection.collapsed(
            offset: selection.start + result.length,
          );
        } else {
          // Replace all text
          _chatInputController.text = result;

          // Set cursor at the end
          _chatInputController.selection = TextSelection.collapsed(
            offset: result.length,
          );
        }

        
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  void _createNewNoteWithContent(String folderId, String content, String messageId) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Note Title'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Enter note title'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                ref.read(workspaceProvider.notifier).createNote(
                  folderId,
                  controller.text.trim(),
                  content,
                  sourceMessageId: messageId,
                );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Added to Notes!')),
                );
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _addContentToNote(note, String content) async {
    // Append content to existing note
    final updatedContent = '${note.content}\n\n$content';
    await ref.read(workspaceProvider.notifier).updateNote(
      note.copyWith(content: updatedContent),
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Added to note!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatProvider);
    final settings = ref.watch(settingsProvider);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (chatState.messages.isNotEmpty) _scrollToBottom();
    });

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
        ],
      ),
      body: Column(
        children: [
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
                  onAddToNotes: !message.isUser
                      ? () => _showAddToNotesDialog(message.text, message.id)
                      : null,
                  onSaveToSnippets: !message.isUser
                      ? () => _showSaveToSnippetsDialog(message.text, message.id)
                      : null,
                );
              },
            ),
          ),

          ChatInput(
            controller: _chatInputController,

            onSend: (text) {
              ref.read(chatProvider.notifier).sendMessage(text);
            },
            onMicTap: _handleMicTap,
            onImageTap: _handleImageTap,
            onSmartEditTap: _showSmartEditMenu,

            isListening: _isListening,
            isLoading: chatState.isLoading,
          ),

        ],
      ),
    );
  }
}


