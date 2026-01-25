import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/workspace_folder.dart';
import '../models/note.dart';
import '../services/database_service.dart';

final workspaceProvider = StateNotifierProvider<WorkspaceNotifier, WorkspaceState>((ref) {
  return WorkspaceNotifier(ref.read(databaseServiceProvider));
});

class WorkspaceState {
  final List<WorkspaceFolder> folders;
  final List<Note> notes;
  final String? currentFolderId;
  final bool isLoading;

  WorkspaceState({
    this.folders = const [],
    this.notes = const [],
    this.currentFolderId,
    this.isLoading = false,
  });

  WorkspaceState copyWith({
    List<WorkspaceFolder>? folders,
    List<Note>? notes,
    String? currentFolderId,
    bool? isLoading,
  }) {
    return WorkspaceState(
      folders: folders ?? this.folders,
      notes: notes ?? this.notes,
      currentFolderId: currentFolderId ?? this.currentFolderId,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class WorkspaceNotifier extends StateNotifier<WorkspaceState> {
  WorkspaceNotifier(this._db) : super(WorkspaceState()) {
    loadFolders();
  }

  final DatabaseService _db;
  final _uuid = const Uuid();

  Future<void> loadFolders({String? parentId}) async {
    state = state.copyWith(isLoading: true);
    final folders = await _db.getFolders(parentId: parentId);
    state = state.copyWith(folders: folders, isLoading: false);
  }

  Future<void> loadNotes(String folderId) async {
    state = state.copyWith(isLoading: true, currentFolderId: folderId);
    final notes = await _db.getNotes(folderId: folderId);
    state = state.copyWith(notes: notes, isLoading: false);
  }

  Future<void> createFolder(String name, {String? parentId}) async {
    final folder = WorkspaceFolder(
      id: _uuid.v4(),
      name: name,
      parentId: parentId,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await _db.insertFolder(folder);
    await loadFolders(parentId: parentId);
  }

  Future<void> createNote(String folderId, String title, String content, {String? sourceMessageId}) async {
    final note = Note(
      id: _uuid.v4(),
      folderId: folderId,
      title: title,
      content: content,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      sourceMessageId: sourceMessageId,
    );
    await _db.insertNote(note);
    await loadNotes(folderId);
  }

  Future<void> updateNote(Note note) async {
    await _db.updateNote(note.copyWith(updatedAt: DateTime.now()));
    if (state.currentFolderId != null) {
      await loadNotes(state.currentFolderId!);
    }
  }

  Future<void> deleteNote(String noteId) async {
    await _db.deleteNote(noteId);
    if (state.currentFolderId != null) {
      await loadNotes(state.currentFolderId!);
    }
  }

  Future<void> deleteFolder(String folderId) async {
    await _db.deleteFolder(folderId);
    await loadFolders();
  }

  Future<List<Note>> searchNotes(String query) async {
    return await _db.searchNotes(query);
  }
}