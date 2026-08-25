class TafsirEdition {
  final String id;
  final String name;
  final String author;
  final String language;

  const TafsirEdition({
    required this.id,
    required this.name,
    required this.author,
    required this.language,
  });

  static const List<TafsirEdition> availableEditions = [
    TafsirEdition(
      id: 'en-tafisr-ibn-kathir',
      name: 'Tafsir Ibn Kathir',
      author: 'Hafiz Ibn Kathir',
      language: 'English',
    ),
    TafsirEdition(
      id: 'ur-tafseer-bayan-ul-quran',
      name: 'Tafseer Bayan ul Quran',
      author: 'Dr. Israr Ahmed',
      language: 'Urdu',
    ),
    TafsirEdition(
      id: 'en-al-jalalayn',
      name: 'Tafsir Al-Jalalayn',
      author: 'Jalal al-Din al-Mahalli & Jalal al-Din al-Suyuti',
      language: 'English',
    ),
  ];

  static TafsirEdition findById(String id) {
    return availableEditions.firstWhere(
      (e) => e.id == id,
      orElse: () => availableEditions.first,
    );
  }
}

class AyahTafsir {
  final int surahNumber;
  final int ayahNumber;
  final String tafsirId;
  final String authorName;
  final String text;
  final String language;
  final DateTime updatedAt;

  const AyahTafsir({
    required this.surahNumber,
    required this.ayahNumber,
    required this.tafsirId,
    required this.authorName,
    required this.text,
    required this.language,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() => {
    'surah_number': surahNumber,
    'ayah_number': ayahNumber,
    'tafsir_id': tafsirId,
    'author_name': authorName,
    'tafsir_text': text,
    'language': language,
    'updated_at': updatedAt.toIso8601String(),
  };

  factory AyahTafsir.fromMap(Map<String, dynamic> map) => AyahTafsir(
    surahNumber: map['surah_number'] as int,
    ayahNumber: map['ayah_number'] as int,
    tafsirId: map['tafsir_id'] as String,
    authorName: map['author_name'] as String,
    text: map['tafsir_text'] as String,
    language: map['language'] as String,
    updatedAt: DateTime.tryParse(map['updated_at']?.toString() ?? '') ?? DateTime.now(),
  );
}
