import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/snippet.dart';
import '../services/database_service.dart';

final snippetsProvider = StateNotifierProvider<SnippetsNotifier, List<Snippet>>((ref) {
  return SnippetsNotifier(ref.read(databaseServiceProvider));
});

class SnippetsNotifier extends StateNotifier<List<Snippet>> {
  SnippetsNotifier(this._db) : super([]) {
    loadSnippets();
  }

  final DatabaseService _db;
  final _uuid = const Uuid();

  Future<void> loadSnippets({SnippetType? type}) async {
    final snippets = await _db.getSnippets(type: type);
    state = snippets;
  }

  Future<void> addSnippet(String content, SnippetType type, {String? sourceMessageId, List<String>? tags}) async {
    final snippet = Snippet(
      id: _uuid.v4(),
      content: content,
      type: type,
      createdAt: DateTime.now(),
      sourceMessageId: sourceMessageId,
      tags: tags ?? [],
    );
    await _db.insertSnippet(snippet);
    await loadSnippets();
  }

  Future<void> deleteSnippet(String id) async {
    await _db.deleteSnippet(id);
    await loadSnippets();
  }
}