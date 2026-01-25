// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import '../models/message.dart';
// import 'dart:convert';
//
// class MessageBubble extends StatelessWidget {
//   final ChatMessage message;
//   final VoidCallback? onSpeak;
//
//   const MessageBubble({
//     super.key,
//     required this.message,
//     this.onSpeak,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Align(
//       alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
//       child: Container(
//         margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
//         padding: const EdgeInsets.all(12),
//         constraints: BoxConstraints(
//           maxWidth: MediaQuery.of(context).size.width * 0.75,
//         ),
//         decoration: BoxDecoration(
//           color: message.isUser
//               ? Theme.of(context).colorScheme.primaryContainer
//               : Theme.of(context).colorScheme.surfaceContainerHighest,
//           borderRadius: BorderRadius.circular(16),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Image if present
//             if (message.imageBase64 != null) ...[
//               ClipRRect(
//                 borderRadius: BorderRadius.circular(8),
//                 child: Image.memory(
//                   base64Decode(message.imageBase64!),
//                   height: 150,
//                   fit: BoxFit.cover,
//                 ),
//               ),
//               const SizedBox(height: 8),
//             ],
//
//             // Message text
//             SelectableText(
//               message.text,
//               style: TextStyle(
//                 color: message.isUser
//                     ? Theme.of(context).colorScheme.onPrimaryContainer
//                     : Theme.of(context).colorScheme.onSurface,
//               ),
//             ),
//
//             const SizedBox(height: 4),
//
//             // Bottom row: timestamp, status, actions
//             Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Text(
//                   _formatTime(message.timestamp),
//                   style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                     color: message.isUser
//                         ? Theme.of(context)
//                         .colorScheme
//                         .onPrimaryContainer
//                         .withOpacity(0.6)
//                         : Theme.of(context)
//                         .colorScheme
//                         .onSurface
//                         .withOpacity(0.6),
//                   ),
//                 ),
//
//                 if (message.status == MessageStatus.error) ...[
//                   const SizedBox(width: 4),
//                   Icon(Icons.error_outline, size: 14, color: Colors.red),
//                 ],
//
//                 const Spacer(),
//
//                 // Action buttons for AI messages
//                 if (!message.isUser) ...[
//                   IconButton(
//                     icon: const Icon(Icons.volume_up, size: 18),
//                     onPressed: onSpeak,
//                     tooltip: 'Read aloud',
//                     iconSize: 18,
//                     padding: EdgeInsets.zero,
//                     constraints: const BoxConstraints(),
//                   ),
//                   const SizedBox(width: 8),
//                   IconButton(
//                     icon: const Icon(Icons.copy, size: 18),
//                     onPressed: () {
//                       Clipboard.setData(ClipboardData(text: message.text));
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         const SnackBar(
//                           content: Text('Copied to clipboard'),
//                           duration: Duration(seconds: 1),
//                         ),
//                       );
//                     },
//                     tooltip: 'Copy',
//                     iconSize: 18,
//                     padding: EdgeInsets.zero,
//                     constraints: const BoxConstraints(),
//                   ),
//                 ],
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   String _formatTime(DateTime time) {
//     return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
//   }
// }



import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/message.dart';
import 'dart:convert';

class MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final VoidCallback? onSpeak;
  final VoidCallback? onAddToNotes;
  final VoidCallback? onSaveToSnippets;

  const MessageBubble({
    super.key,
    required this.message,
    this.onSpeak,
    this.onAddToNotes,
    this.onSaveToSnippets,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        padding: const EdgeInsets.all(12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: message.isUser
              ? Theme.of(context).colorScheme.primaryContainer
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (message.imageBase64 != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.memory(
                  base64Decode(message.imageBase64!),
                  height: 150,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 8),
            ],

            SelectableText(
              message.text,
              style: TextStyle(
                color: message.isUser
                    ? Theme.of(context).colorScheme.onPrimaryContainer
                    : Theme.of(context).colorScheme.onSurface,
              ),
            ),

            const SizedBox(height: 4),

            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _formatTime(message.timestamp),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: message.isUser
                        ? Theme.of(context)
                        .colorScheme
                        .onPrimaryContainer
                        .withOpacity(0.6)
                        : Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.6),
                  ),
                ),

                if (message.status == MessageStatus.error) ...[
                  const SizedBox(width: 4),
                  const Icon(Icons.error_outline, size: 14, color: Colors.red),
                ],

                const Spacer(),

                if (!message.isUser) ...[
                  // Add to Notes button
                  if (onAddToNotes != null)
                    IconButton(
                      icon: const Icon(Icons.note_add, size: 18),
                      onPressed: onAddToNotes,
                      tooltip: 'Add to Notes',
                      iconSize: 18,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  const SizedBox(width: 8),

                  // Save to Snippets button
                  if (onSaveToSnippets != null)
                    IconButton(
                      icon: const Icon(Icons.bookmark_add, size: 18),
                      onPressed: onSaveToSnippets,
                      tooltip: 'Save to Snippets',
                      iconSize: 18,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  const SizedBox(width: 8),

                  // Speak button
                  IconButton(
                    icon: const Icon(Icons.volume_up, size: 18),
                    onPressed: onSpeak,
                    tooltip: 'Read aloud',
                    iconSize: 18,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 8),

                  // Copy button
                  IconButton(
                    icon: const Icon(Icons.copy, size: 18),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: message.text));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Copied to clipboard'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                    tooltip: 'Copy',
                    iconSize: 18,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}