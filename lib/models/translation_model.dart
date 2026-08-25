class TranslationEdition {
  final String id;
  final String name;
  final String author;
  final String language;
  final String languageCode;

  const TranslationEdition({
    required this.id,
    required this.name,
    required this.author,
    required this.language,
    required this.languageCode,
  });

  static const List<TranslationEdition> availableEditions = [
    TranslationEdition(
      id: 'ur.jalandhry',
      name: 'Urdu - Jalandhry',
      author: 'Maulana Fateh Muhammad Jalandhry',
      language: 'Urdu',
      languageCode: 'ur',
    ),
    TranslationEdition(
      id: 'en.sahih',
      name: 'English - Sahih International',
      author: 'Sahih International',
      language: 'English',
      languageCode: 'en',
    ),
    TranslationEdition(
      id: 'en.hilali',
      name: 'English - Hilali & Khan',
      author: 'Muhammad Taqi-ud-Din al-Hilali & Muhammad Muhsin Khan',
      language: 'English',
      languageCode: 'en',
    ),
    TranslationEdition(
      id: 'ur.kanzuliman',
      name: 'Urdu - Kanzul Iman',
      author: 'Ahmed Raza Khan',
      language: 'Urdu',
      languageCode: 'ur',
    ),
  ];

  static TranslationEdition findById(String id) {
    return availableEditions.firstWhere(
      (e) => e.id == id,
      orElse: () => availableEditions.first,
    );
  }
}

class AyahTranslation {
  final int surahNumber;
  final int ayahNumber;
  final String editionId;
  final String text;

  const AyahTranslation({
    required this.surahNumber,
    required this.ayahNumber,
    required this.editionId,
    required this.text,
  });

  Map<String, dynamic> toMap() => {
    'surah_number': surahNumber,
    'ayah_number': ayahNumber,
    'edition_id': editionId,
    'translation_text': text,
  };

  factory AyahTranslation.fromMap(Map<String, dynamic> map) => AyahTranslation(
    surahNumber: map['surah_number'] as int,
    ayahNumber: map['ayah_number'] as int,
    editionId: map['edition_id'] as String,
    text: map['translation_text'] as String,
  );
}
