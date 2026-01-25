class Note {
  final String id;
  final String folderId;
  final String title;
  final String content; // JSON from flutter_quill
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> tags;
  final String? sourceMessageId; // For "Find in Conversation"
  final bool isPinned;

  Note({
    required this.id,
    required this.folderId,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    this.tags = const [],
    this.sourceMessageId,
    this.isPinned = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'folderId': folderId,
    'title': title,
    'content': content,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'tags': tags,
    'sourceMessageId': sourceMessageId,
    'isPinned': isPinned,
  };

  factory Note.fromJson(Map<String, dynamic> json) => Note(
    id: json['id'],
    folderId: json['folderId'],
    title: json['title'],
    content: json['content'],
    createdAt: DateTime.parse(json['createdAt']),
    updatedAt: DateTime.parse(json['updatedAt']),
    tags: List<String>.from(json['tags'] ?? []),
    sourceMessageId: json['sourceMessageId'],
    isPinned: json['isPinned'] ?? false,
  );

  Note copyWith({
    String? id,
    String? folderId,
    String? title,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? tags,
    String? sourceMessageId,
    bool? isPinned,
  }) {
    return Note(
      id: id ?? this.id,
      folderId: folderId ?? this.folderId,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      tags: tags ?? this.tags,
      sourceMessageId: sourceMessageId ?? this.sourceMessageId,
      isPinned: isPinned ?? this.isPinned,
    );
  }
}