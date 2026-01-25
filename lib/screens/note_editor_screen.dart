import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'dart:convert';
import '../models/note.dart';
import '../providers/workspace_provider.dart';
import '../services/ai_service.dart';
import '../services/pdf_service.dart';

class NoteEditorScreen extends ConsumerStatefulWidget {
  final String folderId;
  final Note? note;
  final String? title;

  const NoteEditorScreen({
    super.key,
    required this.folderId,
    this.note,
    this.title,
  });

  @override
  ConsumerState<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends ConsumerState<NoteEditorScreen> {
  late quill.QuillController _controller;
  late TextEditingController _titleController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? widget.title ?? '');

    if (widget.note != null && widget.note!.content.isNotEmpty) {
      try {
        // Parse the JSON content
        final jsonContent = jsonDecode(widget.note!.content);
        final doc = quill.Document.fromJson(jsonContent);
        _controller = quill.QuillController(
          document: doc,
          selection: const TextSelection.collapsed(offset: 0),
        );
      } catch (e) {
        // If parsing fails, treat as plain text
        _controller = quill.QuillController.basic();
        _controller.document.insert(0, widget.note!.content);
      }
    } else {
      _controller = quill.QuillController.basic();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _saveNote() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a title')),
      );
      return;
    }

    setState(() => _isSaving = true);

    final content = jsonEncode(_controller.document.toDelta().toJson());

    if (widget.note != null) {
      await ref.read(workspaceProvider.notifier).updateNote(
        widget.note!.copyWith(
          title: _titleController.text.trim(),
          content: content,
        ),
      );
    } else {
      await ref.read(workspaceProvider.notifier).createNote(
        widget.folderId,
        _titleController.text.trim(),
        content,
      );
    }

    setState(() => _isSaving = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Note saved!')),
      );
      Navigator.pop(context);
    }
  }

  String _getSelectedText() {
    final selection = _controller.selection;
    if (!selection.isValid || selection.isCollapsed) {
      return '';
    }

    final plainText = _controller.document.toPlainText();
    return plainText.substring(selection.start, selection.end);
  }

  void _showSmartEditMenu() {
    final selectedText = _getSelectedText();
    if (selectedText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select text first')),
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
    if (selectedText.isEmpty) return;

    final prompts = {
      'grammar': 'Fix grammar and spelling errors in: "$selectedText"',
      'rephrase': 'Rephrase this text differently: "$selectedText"',
      'simplify': 'Simplify this text: "$selectedText"',
      'professional': 'Make this text more professional: "$selectedText"',
      'expand': 'Expand on this text with more details: "$selectedText"',
      'shorten': 'Make this text shorter and more concise: "$selectedText"',
    };

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final ai = ref.read(aiServiceProvider);
      final stream = ai.sendMessageStream(prompts[action]!);
      String result = '';

      await for (var chunk in stream) {
        result += chunk;
      }

      if (mounted) {
        Navigator.pop(context); // Close loading dialog

        // Replace selected text
        final selection = _controller.selection;
        _controller.replaceText(
          selection.start,
          selection.end - selection.start,
          result.trim(),
          const TextSelection.collapsed(offset: 0),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Text updated!')),
        );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Note'),
        actions: [
          IconButton(
            icon: const Icon(Icons.auto_fix_high),
            onPressed: _showSmartEditMenu,
            tooltip: 'Smart Edit',
          ),
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () async {
              // Save first
              await _saveNote();

              // Then export
              if (widget.note != null && mounted) {
                final pdfService = ref.read(pdfServiceProvider);
                await pdfService.exportNoteToPdf(
                  context,
                  widget.note!,
                  'Note',
                );
              }
            },
            tooltip: 'Export as PDF',
          ),
          IconButton(
            icon: _isSaving
                ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
                : const Icon(Icons.save),
            onPressed: _isSaving ? null : _saveNote,
            tooltip: 'Save',
          ),
        ],
      ),
      body: Column(
        children: [
          // Title field
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                hintText: 'Note Title',
                border: OutlineInputBorder(),
              ),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),

          // Toolbar
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,

              child: quill.QuillSimpleToolbar(
                controller: _controller,
                config: const quill.QuillSimpleToolbarConfig(
                  showAlignmentButtons: true,
                  showBoldButton: true,
                  showItalicButton: true,
                  showUnderLineButton: true,
                  showStrikeThrough: true,
                  showColorButton: true,
                  showBackgroundColorButton: true,
                  showListBullets: true,
                  showListNumbers: true,
                  showCodeBlock: true,
                  showQuote: true,
                  showIndent: true,
                  showLink: false,
                  showUndo: true,
                  showRedo: true,
                  showClearFormat: true,
                ),
              ),
            ),
          ),

          // Editor
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: quill.QuillEditor(
                controller: _controller,
                scrollController: ScrollController(),
                focusNode: FocusNode(),
                config: const quill.QuillEditorConfig(
                  placeholder: 'Start writing your note...',
                  padding: EdgeInsets.all(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}