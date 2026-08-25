class BookmarkFolder {
  final int? id;
  final String name;
  final int colorValue;
  final DateTime createdAt;

  const BookmarkFolder({
    this.id,
    required this.name,
    required this.colorValue,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'name': name,
    'color_value': colorValue,
    'created_at': createdAt.toIso8601String(),
  };

  factory BookmarkFolder.fromMap(Map<String, dynamic> map) => BookmarkFolder(
    id: map['id'] as int?,
    name: map['name'] as String,
    colorValue: map['color_value'] as int? ?? 0xFF0D4D4D,
    createdAt: DateTime.tryParse(map['created_at']?.toString() ?? '') ?? DateTime.now(),
  );

  BookmarkFolder copyWith({
    int? id,
    String? name,
    int? colorValue,
    DateTime? createdAt,
  }) {
    return BookmarkFolder(
      id: id ?? this.id,
      name: name ?? this.name,
      colorValue: colorValue ?? this.colorValue,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
