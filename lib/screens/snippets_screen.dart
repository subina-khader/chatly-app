import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/snippet.dart';
import '../providers/snippets_provider.dart';

class SnippetsScreen extends ConsumerStatefulWidget {
  const SnippetsScreen({super.key});

  @override
  ConsumerState<SnippetsScreen> createState() => _SnippetsScreenState();
}

class _SnippetsScreenState extends ConsumerState<SnippetsScreen> {
  SnippetType? _filterType;

  void _showAddSnippetDialog() {
    final contentController = TextEditingController();
    SnippetType selectedType = SnippetType.text;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add Snippet'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<SnippetType>(
                value: selectedType,
                decoration: const InputDecoration(
                  labelText: 'Type',
                  border: OutlineInputBorder(),
                ),
                items: SnippetType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Row(
                      children: [
                        Icon(_getSnippetIcon(type)),
                        const SizedBox(width: 8),
                        Text(type.name.toUpperCase()),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setDialogState(() => selectedType = value);
                  }
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: contentController,
                decoration: InputDecoration(
                  hintText: _getHintText(selectedType),
                  border: const OutlineInputBorder(),
                ),
                maxLines: 5,
                autofocus: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (contentController.text.trim().isNotEmpty) {
                  ref.read(snippetsProvider.notifier).addSnippet(
                    contentController.text.trim(),
                    selectedType,
                  );
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditSnippetDialog(Snippet snippet) {
    final contentController = TextEditingController(text: snippet.content);
    SnippetType selectedType = snippet.type;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Edit Snippet'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<SnippetType>(
                value: selectedType,
                decoration: const InputDecoration(
                  labelText: 'Type',
                  border: OutlineInputBorder(),
                ),
                items: SnippetType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Row(
                      children: [
                        Icon(_getSnippetIcon(type)),
                        const SizedBox(width: 8),
                        Text(type.name.toUpperCase()),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setDialogState(() => selectedType = value);
                  }
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: contentController,
                decoration: InputDecoration(
                  hintText: _getHintText(selectedType),
                  border: const OutlineInputBorder(),
                ),
                maxLines: 5,
                autofocus: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (contentController.text.trim().isNotEmpty) {
                  ref.read(snippetsProvider.notifier).updateSnippet(
                    snippet.id,
                    contentController.text.trim(),
                    selectedType,
                  );
                  Navigator.pop(context);
                }
              },
              child: const Text('Save'),
            ),
          ],
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

  String _getHintText(SnippetType type) {
    switch (type) {
      case SnippetType.text:
        return 'Enter text...';
      case SnippetType.link:
        return 'Enter URL...';
      case SnippetType.image:
        return 'Enter image URL or description...';
      case SnippetType.audio:
        return 'Enter audio URL...';
      case SnippetType.number:
        return 'Enter phone number or code...';
      case SnippetType.code:
        return 'Enter code snippet...';
    }
  }

  @override
  Widget build(BuildContext context) {
    final snippets = ref.watch(snippetsProvider);
    final filteredSnippets = _filterType == null
        ? snippets
        : snippets.where((s) => s.type == _filterType).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Snippets Vault'),
        actions: [
          PopupMenuButton<SnippetType?>(
            icon: const Icon(Icons.filter_list),
            onSelected: (type) {
              setState(() => _filterType = type);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: null,
                child: Text('All Types'),
              ),
              ...SnippetType.values.map((type) => PopupMenuItem(
                value: type,
                child: Row(
                  children: [
                    Icon(_getSnippetIcon(type)),
                    const SizedBox(width: 8),
                    Text(type.name.toUpperCase()),
                  ],
                ),
              )),
            ],
          ),
        ],
      ),
      body: filteredSnippets.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bookmark_outline, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No snippets yet',
              style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 8),
            Text(
              'Save quick notes, links, and ideas',
              style: TextStyle(color: Colors.grey.shade500),
            ),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filteredSnippets.length,
        itemBuilder: (context, index) {
          final snippet = filteredSnippets[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: Icon(_getSnippetIcon(snippet.type)),
              ),
              title: Text(
                snippet.content,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                _formatDate(snippet.createdAt),
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.copy, size: 20),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: snippet.content));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Copied to clipboard')),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, size: 20),
                    onPressed: () => _showEditSnippetDialog(snippet),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                    onPressed: () {
                      ref.read(snippetsProvider.notifier).deleteSnippet(snippet.id);
                    },
                  ),
                ],
              ),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Row(
                      children: [
                        Icon(_getSnippetIcon(snippet.type)),
                        const SizedBox(width: 8),
                        Text(snippet.type.name.toUpperCase()),
                      ],
                    ),
                    content: SelectableText(snippet.content),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: snippet.content));
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Copied!')),
                          );
                        },
                        child: const Text('Copy'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _showEditSnippetDialog(snippet);
                        },
                        child: const Text('Edit'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Close'),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'snippets_fab',
        onPressed: _showAddSnippetDialog,
        icon: const Icon(Icons.add),
        label: const Text('Add Snippet'),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${date.day}/${date.month}/${date.year}';
  }
}