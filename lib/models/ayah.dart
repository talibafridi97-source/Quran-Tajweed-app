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

    return Ayah(
      number: json['number'] ?? 0,
      text: json['text'] ?? '',
      numberInSurah: json['numberInSurah'] ?? 0,
      juz: json['juz'] ?? 1,
      manzil: json['manzil'] ?? 1,
      page: json['page'] ?? 1,
      ruku: json['ruku'] ?? 1,
      hizbQuarter: json['hizbQuarter'] ?? 1,
      sajda: isSajda,
      surahNumber: sNum,
      surahName: sName,
      surahEnglishName: sEngName,
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
  };
}
