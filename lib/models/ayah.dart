import 'quran_word.dart';

class Ayah {
  final int number;
  final String text;
  final int numberInSurah;
  final int juz;
  final int manzil;
  final int page;
  final int ruku;
  final int hizbQuarter;
  final bool sajda;
  final int? surahNumber;
  final String? surahName;
  final String? surahEnglishName;
  final String? verseKey;
  final List<QuranWord> words;

  Ayah({
    required this.number,
    required this.text,
    required this.numberInSurah,
    required this.juz,
    required this.manzil,
    required this.page,
    required this.ruku,
    required this.hizbQuarter,
    required this.sajda,
    this.surahNumber,
    this.surahName,
    this.surahEnglishName,
    this.verseKey,
    this.words = const [],
  });

  factory Ayah.fromJson(Map<String, dynamic> json) {
    int? sNum;
    String? sName;
    String? sEngName;

    if (json['surah'] != null && json['surah'] is Map) {
      sNum = json['surah']['number'];
      sName = json['surah']['name'];
      sEngName = json['surah']['englishName'];
    } else {
      sNum = json['surahNumber'];
      sName = json['surahName'];
      sEngName = json['surahEnglishName'];
    }

    bool isSajda = false;
    if (json['sajda'] is bool) {
      isSajda = json['sajda'];
    } else if (json['sajda'] is Map) {
      isSajda = true;
    }

    final vKey = json['verse_key']?.toString() ?? json['verseKey']?.toString();

    List<QuranWord> parsedWords = [];
    if (json['words'] != null && json['words'] is List) {
      parsedWords = (json['words'] as List)
          .map((w) => QuranWord.fromJson(w as Map<String, dynamic>, verseKey: vKey))
          .toList();
    }

    return Ayah(
      number: json['number'] ?? json['id'] ?? 0,
      text: json['text'] ?? json['text_uthmani'] ?? '',
      numberInSurah: json['numberInSurah'] ?? json['verse_number'] ?? 0,
      juz: json['juz'] ?? json['juz_number'] ?? 1,
      manzil: json['manzil'] ?? json['manzil_number'] ?? 1,
      page: json['page'] ?? json['page_number'] ?? json['v2_page'] ?? 1,
      ruku: json['ruku'] ?? json['ruku_number'] ?? 1,
      hizbQuarter: json['hizbQuarter'] ?? json['rub_el_hizb_number'] ?? 1,
      sajda: isSajda,
      surahNumber: sNum,
      surahName: sName,
      surahEnglishName: sEngName,
      verseKey: vKey,
      words: parsedWords,
    );
  }

  Map<String, dynamic> toJson() => {
    'number': number,
    'text': text,
    'numberInSurah': numberInSurah,
    'juz': juz,
    'manzil': manzil,
    'page': page,
    'ruku': ruku,
    'hizbQuarter': hizbQuarter,
    'sajda': sajda,
    'surahNumber': surahNumber,
    'surahName': surahName,
    'surahEnglishName': surahEnglishName,
    'verse_key': verseKey,
    'words': words.map((w) => w.toJson()).toList(),
  };
}
