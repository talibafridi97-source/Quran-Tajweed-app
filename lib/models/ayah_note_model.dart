class AyahNote {
  final int? id;
  final int surahNumber;
  final int ayahNumber;
  final String surahName;
  final String surahEnglishName;
  final String noteText;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AyahNote({
    this.id,
    required this.surahNumber,
    required this.ayahNumber,
    required this.surahName,
    required this.surahEnglishName,
    required this.noteText,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'surah_number': surahNumber,
    'ayah_number': ayahNumber,
    'surah_name': surahName,
    'surah_english_name': surahEnglishName,
    'note_text': noteText,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };

  factory AyahNote.fromMap(Map<String, dynamic> map) => AyahNote(
    id: map['id'] as int?,
    surahNumber: map['surah_number'] as int,
    ayahNumber: map['ayah_number'] as int,
    surahName: map['surah_name'] as String? ?? 'Surah',
    surahEnglishName: map['surah_english_name'] as String? ?? 'Surah',
    noteText: map['note_text'] as String,
    createdAt: DateTime.tryParse(map['created_at']?.toString() ?? '') ?? DateTime.now(),
    updatedAt: DateTime.tryParse(map['updated_at']?.toString() ?? '') ?? DateTime.now(),
  );

  AyahNote copyWith({
    int? id,
    int? surahNumber,
    int? ayahNumber,
    String? surahName,
    String? surahEnglishName,
    String? noteText,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AyahNote(
      id: id ?? this.id,
      surahNumber: surahNumber ?? this.surahNumber,
      ayahNumber: ayahNumber ?? this.ayahNumber,
      surahName: surahName ?? this.surahName,
      surahEnglishName: surahEnglishName ?? this.surahEnglishName,
      noteText: noteText ?? this.noteText,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
