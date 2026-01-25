import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/workspace_folder.dart';
import '../models/note.dart';
import '../models/snippet.dart';
import '../models/learning_card.dart';

final databaseServiceProvider = Provider<DatabaseService>((ref) => DatabaseService());

class DatabaseService {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'chatly.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Folders table
    await db.execute('''
      CREATE TABLE folders (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        parentId TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        icon TEXT,
        color TEXT
      )
    ''');

    // Notes table
    await db.execute('''
      CREATE TABLE notes (
        id TEXT PRIMARY KEY,
        folderId TEXT NOT NULL,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        tags TEXT,
        sourceMessageId TEXT,
        isPinned INTEGER DEFAULT 0
      )
    ''');

    // Snippets table
    await db.execute('''
      CREATE TABLE snippets (
        id TEXT PRIMARY KEY,
        content TEXT NOT NULL,
        type TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        tags TEXT,
        sourceMessageId TEXT,
        metadata TEXT
      )
    ''');

    // Learning cards table
    await db.execute('''
      CREATE TABLE learning_cards (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        category TEXT NOT NULL,
        content TEXT NOT NULL,
        lastRefreshed TEXT NOT NULL,
        nextRefreshDue TEXT,
        refreshIntervalDays INTEGER DEFAULT 1,
        isCustom INTEGER DEFAULT 0,
        savedContent TEXT
      )
    ''');
  }

  // ==================== FOLDERS ====================

  Future<List<WorkspaceFolder>> getFolders({String? parentId}) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'folders',
      where: parentId != null ? 'parentId = ?' : 'parentId IS NULL',
      whereArgs: parentId != null ? [parentId] : null,
      orderBy: 'updatedAt DESC',
    );
    return maps.map((map) => WorkspaceFolder.fromJson(map)).toList();
  }

  Future<void> insertFolder(WorkspaceFolder folder) async {
    final db = await database;
    await db.insert('folders', folder.toJson());
  }

  Future<void> updateFolder(WorkspaceFolder folder) async {
    final db = await database;
    await db.update('folders', folder.toJson(), where: 'id = ?', whereArgs: [folder.id]);
  }

  Future<void> deleteFolder(String id) async {
    final db = await database;
    await db.delete('notes', where: 'folderId = ?', whereArgs: [id]);
    await db.delete('folders', where: 'id = ?', whereArgs: [id]);
  }

  // ==================== NOTES ====================

  Future<List<Note>> getNotes({String? folderId}) async {
    final db = await database;
    final maps = await db.query(
      'notes',
      where: folderId != null ? 'folderId = ?' : null,
      whereArgs: folderId != null ? [folderId] : null,
      orderBy: 'isPinned DESC, updatedAt DESC',
    );
    return maps.map((map) {
      final noteMap = Map<String, dynamic>.from(map);
      noteMap['tags'] = (map['tags'] as String?)?.split(',') ?? [];
      noteMap['isPinned'] = map['isPinned'] == 1;
      return Note.fromJson(noteMap);
    }).toList();
  }

  Future<void> insertNote(Note note) async {
    final db = await database;
    final noteMap = note.toJson();
    noteMap['tags'] = note.tags.join(',');
    noteMap['isPinned'] = note.isPinned ? 1 : 0;
    await db.insert('notes', noteMap);
  }

  Future<void> updateNote(Note note) async {
    final db = await database;
    final noteMap = note.toJson();
    noteMap['tags'] = note.tags.join(',');
    noteMap['isPinned'] = note.isPinned ? 1 : 0;
    await db.update('notes', noteMap, where: 'id = ?', whereArgs: [note.id]);
  }

  Future<void> deleteNote(String id) async {
    final db = await database;
    await db.delete('notes', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Note>> searchNotes(String query) async {
    final db = await database;
    final maps = await db.query(
      'notes',
      where: 'title LIKE ? OR content LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
    );
    return maps.map((map) {
      final noteMap = Map<String, dynamic>.from(map);
      noteMap['tags'] = (map['tags'] as String?)?.split(',') ?? [];
      noteMap['isPinned'] = map['isPinned'] == 1;
      return Note.fromJson(noteMap);
    }).toList();
  }

  // ==================== SNIPPETS ====================

  Future<List<Snippet>> getSnippets({SnippetType? type}) async {
    final db = await database;
    final maps = await db.query(
      'snippets',
      where: type != null ? 'type = ?' : null,
      whereArgs: type != null ? [type.name] : null,
      orderBy: 'createdAt DESC',
    );
    return maps.map((map) {
      final snippetMap = Map<String, dynamic>.from(map);
      snippetMap['tags'] = (map['tags'] as String?)?.split(',') ?? [];
      return Snippet.fromJson(snippetMap);
    }).toList();
  }

  Future<void> insertSnippet(Snippet snippet) async {
    final db = await database;
    final snippetMap = snippet.toJson();
    snippetMap['tags'] = snippet.tags.join(',');
    await db.insert('snippets', snippetMap);
  }

  Future<void> deleteSnippet(String id) async {
    final db = await database;
    await db.delete('snippets', where: 'id = ?', whereArgs: [id]);
  }

  // ==================== LEARNING CARDS ====================

  Future<List<LearningCard>> getLearningCards() async {
    final db = await database;
    final maps = await db.query('learning_cards', orderBy: 'lastRefreshed DESC');
    return maps.map((map) {
      final cardMap = Map<String, dynamic>.from(map);
      cardMap['isCustom'] = map['isCustom'] == 1;
      cardMap['savedContent'] = (map['savedContent'] as String?)?.split('|||') ?? [];
      return LearningCard.fromJson(cardMap);
    }).toList();
  }

  Future<void> insertLearningCard(LearningCard card) async {
    final db = await database;
    final cardMap = card.toJson();
    cardMap['isCustom'] = card.isCustom ? 1 : 0;
    cardMap['savedContent'] = card.savedContent.join('|||');
    await db.insert('learning_cards', cardMap);
  }

  Future<void> updateLearningCard(LearningCard card) async {
    final db = await database;
    final cardMap = card.toJson();
    cardMap['isCustom'] = card.isCustom ? 1 : 0;
    cardMap['savedContent'] = card.savedContent.join('|||');
    await db.update('learning_cards', cardMap, where: 'id = ?', whereArgs: [card.id]);
  }

  Future<void> deleteLearningCard(String id) async {
    final db = await database;
    await db.delete('learning_cards', where: 'id = ?', whereArgs: [id]);
  }
}