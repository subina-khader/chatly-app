class WorkspaceFolder {
  final String id;
  final String name;
  final String? parentId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? icon;
  final String? color;

  WorkspaceFolder({
    required this.id,
    required this.name,
    this.parentId,
    required this.createdAt,
    required this.updatedAt,
    this.icon,
    this.color,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'parentId': parentId,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'icon': icon,
    'color': color,
  };

  factory WorkspaceFolder.fromJson(Map<String, dynamic> json) => WorkspaceFolder(
    id: json['id'],
    name: json['name'],
    parentId: json['parentId'],
    createdAt: DateTime.parse(json['createdAt']),
    updatedAt: DateTime.parse(json['updatedAt']),
    icon: json['icon'],
    color: json['color'],
  );

  WorkspaceFolder copyWith({
    String? id,
    String? name,
    String? parentId,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? icon,
    String? color,
  }) {
    return WorkspaceFolder(
      id: id ?? this.id,
      name: name ?? this.name,
      parentId: parentId ?? this.parentId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      icon: icon ?? this.icon,
      color: color ?? this.color,
    );
  }
}