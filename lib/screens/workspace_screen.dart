import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/workspace_provider.dart';
import '../services/pdf_service.dart';
import 'note_editor_screen.dart';
import '../models/note.dart';
class WorkspaceScreen extends ConsumerStatefulWidget {
  const WorkspaceScreen({super.key});

  @override
  ConsumerState<WorkspaceScreen> createState() => _WorkspaceScreenState();
}

class _WorkspaceScreenState extends ConsumerState<WorkspaceScreen> {
  String? _currentFolderId;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showCreateFolderDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Folder'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Folder name (e.g., Flutter, Python)',
            border: OutlineInputBorder(),
          ),
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
                ref.read(workspaceProvider.notifier).createFolder(
                  controller.text.trim(),
                  parentId: _currentFolderId,
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showCreateNoteDialog() {
    if (_currentFolderId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a folder first')),
      );
      return;
    }

    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Note'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Note title',
            border: OutlineInputBorder(),
          ),
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
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => NoteEditorScreen(
                      folderId: _currentFolderId!,
                      title: controller.text.trim(),
                    ),
                  ),
                );
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final workspaceState = ref.watch(workspaceProvider);

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Search notes...',
            border: InputBorder.none,
          ),
          autofocus: true,
          onChanged: (query) {
            if (query.isNotEmpty) {
              // Trigger search
              ref.read(workspaceProvider.notifier).searchNotes(query);
            }
          },
        )
            : Text(_currentFolderId == null ? 'Workspace' : 'Notes'),
        leading: _currentFolderId != null
            ? IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            setState(() => _currentFolderId = null);
            ref.read(workspaceProvider.notifier).loadFolders();
          },
        )
            : null,
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  if (_currentFolderId != null) {
                    ref.read(workspaceProvider.notifier).loadNotes(_currentFolderId!);
                  }
                }
              });
            },
          ),
          PopupMenuButton(
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'export_note_pdf',
                child: Row(
                  children: [
                    Icon(Icons.picture_as_pdf),
                    SizedBox(width: 8),
                    Text('Export Note as PDF'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'export_folder_pdf',
                child: Row(
                  children: [
                    Icon(Icons.folder_zip),
                    SizedBox(width: 8),
                    Text('Export Folder as PDF'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'import',
                child: Row(
                  children: [
                    Icon(Icons.upload_file),
                    SizedBox(width: 8),
                    Text('Import Notes'),
                  ],
                ),
              ),
            ],
            onSelected: (value) async {
              final pdfService = ref.read(pdfServiceProvider);
              final workspaceState = ref.read(workspaceProvider);

              if (value == 'export_note_pdf') {
                // Export single note
                if (_currentFolderId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please select a folder first')),
                  );
                  return;
                }

                if (workspaceState.notes.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('No notes to export')),
                  );
                  return;
                }

                // Show note selection dialog
                final selectedNote = await showDialog<Note>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Select Note to Export'),
                    content: SizedBox(
                      width: double.maxFinite,
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: workspaceState.notes.length,
                        itemBuilder: (context, index) {
                          final note = workspaceState.notes[index];
                          return ListTile(
                            leading: const Icon(Icons.note),
                            title: Text(note.title),
                            onTap: () => Navigator.pop(context, note),
                          );
                        },
                      ),
                    ),
                  ),
                );

                if (selectedNote != null && mounted) {
                  final folder = workspaceState.folders.firstWhere(
                        (f) => f.id == _currentFolderId,
                  );
                  await pdfService.exportNoteToPdf(context, selectedNote, folder.name);
                }
              } else if (value == 'export_folder_pdf') {
                // Export entire folder
                if (_currentFolderId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please select a folder first')),
                  );
                  return;
                }

                final folder = workspaceState.folders.firstWhere(
                      (f) => f.id == _currentFolderId,
                );
                final notes = workspaceState.notes;

                if (mounted) {
                  await pdfService.exportFolderToPdf(context, folder, notes);
                }
              } else if (value == 'import') {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Import feature coming soon!')),
                );
              }
            },
          ),
        ],
      ),
      body: workspaceState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : _currentFolderId == null
          ? _buildFoldersView(workspaceState)
          : _buildNotesView(workspaceState),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'workspace_fab', // Add unique hero tag
        onPressed: _currentFolderId == null ? _showCreateFolderDialog : _showCreateNoteDialog,
        icon: Icon(_currentFolderId == null ? Icons.create_new_folder : Icons.note_add),
        label: Text(_currentFolderId == null ? 'New Folder' : 'New Note'),
      ),    );
  }

  Widget _buildFoldersView(WorkspaceState state) {
    if (state.folders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_outlined, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No folders yet',
              style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 8),
            Text(
              'Create folders to organize your notes',
              style: TextStyle(color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: state.folders.length,
      itemBuilder: (context, index) {
        final folder = state.folders[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: const Icon(Icons.folder),
            ),
            title: Text(
              folder.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              'Updated ${_formatDate(folder.updatedAt)}',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            trailing: PopupMenuButton(
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Delete'),
                    ],
                  ),
                ),
              ],
              onSelected: (value) async {
                if (value == 'delete') {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Delete Folder'),
                      content: const Text('This will delete all notes inside. Continue?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: TextButton.styleFrom(foregroundColor: Colors.red),
                          child: const Text('Delete'),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    ref.read(workspaceProvider.notifier).deleteFolder(folder.id);
                  }
                }
              },
            ),
            onTap: () {
              setState(() => _currentFolderId = folder.id);
              ref.read(workspaceProvider.notifier).loadNotes(folder.id);
            },
          ),
        );
      },
    );
  }

  Widget _buildNotesView(WorkspaceState state) {
    if (state.notes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.note_outlined, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No notes yet',
              style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 8),
            Text(
              'Create your first note',
              style: TextStyle(color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: state.notes.length,
      itemBuilder: (context, index) {
        final note = state.notes[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Icon(
              note.isPinned ? Icons.push_pin : Icons.note,
              color: note.isPinned ? Colors.orange : null,
            ),
            title: Text(
              note.title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  _getPreviewText(note.content),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 4),
                Text(
                  'Updated ${_formatDate(note.updatedAt)}',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                ),
              ],
            ),
            trailing: PopupMenuButton(
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'pin',
                  child: Row(
                    children: [
                      Icon(note.isPinned ? Icons.push_pin_outlined : Icons.push_pin),
                      const SizedBox(width: 8),
                      Text(note.isPinned ? 'Unpin' : 'Pin'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'export_pdf',
                  child: Row(
                    children: [
                      Icon(Icons.picture_as_pdf),
                      SizedBox(width: 8),
                      Text('Export as PDF'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Delete'),
                    ],
                  ),
                ),
              ],
              onSelected: (value) async {
                if (value == 'pin') {
                  ref.read(workspaceProvider.notifier).updateNote(
                    note.copyWith(isPinned: !note.isPinned),
                  );
                } else if (value == 'export_pdf') {
                  final folder = ref.read(workspaceProvider).folders.firstWhere(
                        (f) => f.id == _currentFolderId,
                  );
                  await ref.read(pdfServiceProvider).exportNoteToPdf(
                    context,
                    note,
                    folder.name,
                  );
                } else if (value == 'delete') {
                  ref.read(workspaceProvider.notifier).deleteNote(note.id);
                }
              },
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => NoteEditorScreen(
                    folderId: note.folderId,
                    note: note,
                  ),
                ),
              );
            },
          ),
        );
      },
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

  String _getPreviewText(String content) {
    // Simple preview - extract plain text from content
    return content.replaceAll(RegExp(r'[^\w\s]'), ' ').trim();
  }
}