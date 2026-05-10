class Note {
  const Note({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    required this.isFavorite,
    required this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String title;
  final String content;
  final String category;
  final bool isFavorite;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'content': content,
      'category': category,
      'isFavorite': isFavorite,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      category: json['category'] as String,
      isFavorite: json['isFavorite'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );
  }

  Note copyWith({
    String? id,
    String? title,
    String? content,
    String? category,
    bool? isFavorite,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool clearUpdatedAt = false,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      category: category ?? this.category,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: clearUpdatedAt ? null : (updatedAt ?? this.updatedAt),
    );
  }
}
