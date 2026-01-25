class LearningCard {
  final String id;
  final String title;
  final String category;
  final String content;
  final DateTime lastRefreshed;
  final DateTime? nextRefreshDue;
  final int refreshIntervalDays;
  final bool isCustom;
  final List<String> savedContent;

  LearningCard({
    required this.id,
    required this.title,
    required this.category,
    required this.content,
    required this.lastRefreshed,
    this.nextRefreshDue,
    this.refreshIntervalDays = 1,
    this.isCustom = false,
    this.savedContent = const [],
  });

  bool get needsRefresh {
    if (nextRefreshDue == null) return true;
    return DateTime.now().isAfter(nextRefreshDue!);
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'category': category,
    'content': content,
    'lastRefreshed': lastRefreshed.toIso8601String(),
    'nextRefreshDue': nextRefreshDue?.toIso8601String(),
    'refreshIntervalDays': refreshIntervalDays,
    'isCustom': isCustom,
    'savedContent': savedContent,
  };

  factory LearningCard.fromJson(Map<String, dynamic> json) => LearningCard(
    id: json['id'],
    title: json['title'],
    category: json['category'],
    content: json['content'],
    lastRefreshed: DateTime.parse(json['lastRefreshed']),
    nextRefreshDue: json['nextRefreshDue'] != null
        ? DateTime.parse(json['nextRefreshDue'])
        : null,
    refreshIntervalDays: json['refreshIntervalDays'] ?? 1,
    isCustom: json['isCustom'] ?? false,
    savedContent: List<String>.from(json['savedContent'] ?? []),
  );

  LearningCard copyWith({
    String? id,
    String? title,
    String? category,
    String? content,
    DateTime? lastRefreshed,
    DateTime? nextRefreshDue,
    int? refreshIntervalDays,
    bool? isCustom,
    List<String>? savedContent,
  }) {
    return LearningCard(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      content: content ?? this.content,
      lastRefreshed: lastRefreshed ?? this.lastRefreshed,
      nextRefreshDue: nextRefreshDue ?? this.nextRefreshDue,
      refreshIntervalDays: refreshIntervalDays ?? this.refreshIntervalDays,
      isCustom: isCustom ?? this.isCustom,
      savedContent: savedContent ?? this.savedContent,
    );
  }
}