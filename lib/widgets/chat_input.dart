import 'package:flutter/material.dart';

class ChatInput extends StatefulWidget {
  final Function(String) onSend;
  final VoidCallback onMicTap;
  final VoidCallback onImageTap;
  final bool isListening;
  final bool isLoading;

  const ChatInput({
    super.key,
    required this.onSend,
    required this.onMicTap,
    required this.onImageTap,
    this.isListening = false,
    this.isLoading = false,
  });

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  final TextEditingController _controller = TextEditingController();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {
        _hasText = _controller.text.trim().isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleSend() {
    final text = _controller.text.trim();
    if (text.isNotEmpty && !widget.isLoading) {
      widget.onSend(text);
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Image button
            IconButton(
              icon: const Icon(Icons.image),
              onPressed: widget.isLoading ? null : widget.onImageTap,
              color: Theme.of(context).colorScheme.primary,
            ),

            // Text input
            Expanded(
              child: TextField(
                controller: _controller,
                enabled: !widget.isLoading,
                decoration: InputDecoration(
                  hintText: widget.isListening
                      ? 'Listening...'
                      : 'Ask anything...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                ),
                maxLines: 4,
                minLines: 1,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _handleSend(),
              ),
            ),

            const SizedBox(width: 8),

            // Mic or Send button
            if (_hasText)
              IconButton(
                icon: widget.isLoading
                    ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : const Icon(Icons.send),
                onPressed: widget.isLoading ? null : _handleSend,
                color: Theme.of(context).colorScheme.primary,
              )
            else
              IconButton(
                icon: Icon(
                  widget.isListening ? Icons.mic : Icons.mic_none,
                ),
                onPressed: widget.isLoading ? null : widget.onMicTap,
                color: widget.isListening
                    ? Colors.red
                    : Theme.of(context).colorScheme.primary,
              ),
          ],
        ),
      ),
    );
  }
}