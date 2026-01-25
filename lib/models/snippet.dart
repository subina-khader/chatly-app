enum SnippetType { text, link, image, audio, number, code }

class Snippet {
  final String id;
  final String content;
  final SnippetType type;
  final DateTime createdAt;
  final List<String> tags;
  final String? sourceMessageId;
  final String? metadata; // For storing additional info

  Snippet({
    required this.id,
    required this.content,
    required this.type,
    required this.createdAt,
    this.tags = const [],
    this.sourceMessageId,
    this.metadata,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'content': content,
    'type': type.name,
    'createdAt': createdAt.toIso8601String(),
    'tags': tags,
    'sourceMessageId': sourceMessageId,
    'metadata': metadata,
  };

  factory Snippet.fromJson(Map<String, dynamic> json) => Snippet(
    id: json['id'],
    content: json['content'],
    type: SnippetType.values.firstWhere((e) => e.name == json['type']),
    createdAt: DateTime.parse(json['createdAt']),
    tags: List<String>.from(json['tags'] ?? []),
    sourceMessageId: json['sourceMessageId'],
    metadata: json['metadata'],
  );
}