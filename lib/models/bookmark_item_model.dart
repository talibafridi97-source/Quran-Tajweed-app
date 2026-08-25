class BookmarkItem {
  final int? id;
  final int surahNumber;
  final int ayahNumber;
  final String surahName;
  final String surahEnglishName;
  final int pageNumber;
  final int? folderId;
  final String? ayahText;
  final DateTime createdAt;

  const BookmarkItem({
    this.id,
    required this.surahNumber,
    required this.ayahNumber,
    required this.surahName,
    required this.surahEnglishName,
    required this.pageNumber,
    this.folderId,
    this.ayahText,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'surah_number': surahNumber,
    'ayah_number': ayahNumber,
    'surah_name': surahName,
    'surah_english_name': surahEnglishName,
    'page_number': pageNumber,
    'folder_id': folderId,
    'ayah_text': ayahText,
    'created_at': createdAt.toIso8601String(),
  };

  factory BookmarkItem.fromMap(Map<String, dynamic> map) => BookmarkItem(
    id: map['id'] as int?,
    surahNumber: map['surah_number'] as int,
    ayahNumber: map['ayah_number'] as int,
    surahName: map['surah_name'] as String? ?? 'Surah',
    surahEnglishName: map['surah_english_name'] as String? ?? 'Surah',
    pageNumber: map['page_number'] as int? ?? 1,
    folderId: map['folder_id'] as int?,
    ayahText: map['ayah_text'] as String?,
    createdAt: DateTime.tryParse(map['created_at']?.toString() ?? '') ?? DateTime.now(),
  );

  BookmarkItem copyWith({
    int? id,
    int? surahNumber,
    int? ayahNumber,
    String? surahName,
    String? surahEnglishName,
    int? pageNumber,
    int? folderId,
    String? ayahText,
    DateTime? createdAt,
  }) {
    return BookmarkItem(
      id: id ?? this.id,
      surahNumber: surahNumber ?? this.surahNumber,
      ayahNumber: ayahNumber ?? this.ayahNumber,
      surahName: surahName ?? this.surahName,
      surahEnglishName: surahEnglishName ?? this.surahEnglishName,
      pageNumber: pageNumber ?? this.pageNumber,
      folderId: folderId ?? this.folderId,
      ayahText: ayahText ?? this.ayahText,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
