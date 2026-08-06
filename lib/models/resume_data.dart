class ResumeData {
  final int surahNumber;
  final int ayahNumber;
  final String surahName;
  final int page;
  final int juz;
  final DateTime lastRead;

  ResumeData({
    required this.surahNumber,
    required this.ayahNumber,
    required this.surahName,
    required this.page,
    required this.juz,
    required this.lastRead,
  });

  Map<String, dynamic> toJson() => {
    'surahNumber': surahNumber,
    'ayahNumber': ayahNumber,
    'surahName': surahName,
    'page': page,
    'juz': juz,
    'lastRead': lastRead.toIso8601String(),
  };

  factory ResumeData.fromJson(Map<String, dynamic> json) => ResumeData(
    surahNumber: json['surahNumber'],
    ayahNumber: json['ayahNumber'],
    surahName: json['surahName'],
    page: json['page'],
    juz: json['juz'],
    lastRead: DateTime.parse(json['lastRead']),
  );
}
