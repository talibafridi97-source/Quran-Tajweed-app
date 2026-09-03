enum MushafLineType {
  text,
  surahHeader,
  bismillah,
  empty,
}

class MushafLineSegment {
  final String text;
  final int surahNumber;
  final int ayahNumberInSurah;
  final String verseKey;
  final bool isAyahEnd;
  final int? ayahNumber;

  const MushafLineSegment({
    required this.text,
    required this.surahNumber,
    required this.ayahNumberInSurah,
    required this.verseKey,
    this.isAyahEnd = false,
    this.ayahNumber,
  });

  Map<String, dynamic> toJson() => {
    'text': text,
    'surahNumber': surahNumber,
    'ayahNumberInSurah': ayahNumberInSurah,
    'verseKey': verseKey,
    'isAyahEnd': isAyahEnd,
    'ayahNumber': ayahNumber,
  };

  factory MushafLineSegment.fromJson(Map<String, dynamic> json) {
    return MushafLineSegment(
      text: json['text'] as String? ?? '',
      surahNumber: json['surahNumber'] as int? ?? 1,
      ayahNumberInSurah: json['ayahNumberInSurah'] as int? ?? 1,
      verseKey: json['verseKey'] as String? ?? '1:1',
      isAyahEnd: json['isAyahEnd'] as bool? ?? false,
      ayahNumber: json['ayahNumber'] as int?,
    );
  }
}

class Mushaf16Line {
  final int lineNumber; // 1 to 16
  final MushafLineType type;
  final int surahNumber;
  final String surahName;
  final List<MushafLineSegment> segments;
  final List<int> ayahNumbers;
  final bool isParaStart;
  final int? juzNumber;
  final bool isRukuEnd;
  final int? rukuSurahNumber;
  final int? rukuAyahCount;
  final int? rukuJuzNumber;
  final bool isSajda;
  final int manzilNumber;
  final bool isManzilStart;

  const Mushaf16Line({
    required this.lineNumber,
    this.type = MushafLineType.text,
    required this.surahNumber,
    required this.surahName,
    this.segments = const [],
    this.ayahNumbers = const [],
    this.isParaStart = false,
    this.juzNumber,
    this.isRukuEnd = false,
    this.rukuSurahNumber,
    this.rukuAyahCount,
    this.rukuJuzNumber,
    this.isSajda = false,
    this.manzilNumber = 1,
    this.isManzilStart = false,
  });

  bool get isSurahHeader => type == MushafLineType.surahHeader;
  bool get isBismillah => type == MushafLineType.bismillah;
  bool get isEmpty => type == MushafLineType.empty;
  bool get isText => type == MushafLineType.text;

  String get lineText => segments.map((s) => s.text).join(' ');

  Map<String, dynamic> toJson() => {
    'lineNumber': lineNumber,
    'type': type.name,
    'surahNumber': surahNumber,
    'surahName': surahName,
    'segments': segments.map((s) => s.toJson()).toList(),
    'ayahNumbers': ayahNumbers,
    'isParaStart': isParaStart,
    'juzNumber': juzNumber,
    'isRukuEnd': isRukuEnd,
    'rukuSurahNumber': rukuSurahNumber,
    'rukuAyahCount': rukuAyahCount,
    'rukuJuzNumber': rukuJuzNumber,
    'isSajda': isSajda,
    'manzilNumber': manzilNumber,
    'isManzilStart': isManzilStart,
  };

  factory Mushaf16Line.fromJson(Map<String, dynamic> json) {
    return Mushaf16Line(
      lineNumber: json['lineNumber'] as int? ?? 1,
      type: MushafLineType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => MushafLineType.text,
      ),
      surahNumber: json['surahNumber'] as int? ?? 1,
      surahName: json['surahName'] as String? ?? 'Al-Fatihah',
      segments: (json['segments'] as List? ?? [])
          .map((s) => MushafLineSegment.fromJson(s as Map<String, dynamic>))
          .toList(),
      ayahNumbers: (json['ayahNumbers'] as List? ?? []).cast<int>(),
      isParaStart: json['isParaStart'] as bool? ?? false,
      juzNumber: json['juzNumber'] as int?,
      isRukuEnd: json['isRukuEnd'] as bool? ?? false,
      rukuSurahNumber: json['rukuSurahNumber'] as int?,
      rukuAyahCount: json['rukuAyahCount'] as int?,
      rukuJuzNumber: json['rukuJuzNumber'] as int?,
      isSajda: json['isSajda'] as bool? ?? false,
      manzilNumber: json['manzilNumber'] as int? ?? 1,
      isManzilStart: json['isManzilStart'] as bool? ?? false,
    );
  }
}

class Mushaf16LinePage {
  final int pageNumber;
  final int juzNumber;
  final int surahNumber;
  final String surahName;
  final List<Mushaf16Line> lines; // Exactly 16 lines

  const Mushaf16LinePage({
    required this.pageNumber,
    required this.juzNumber,
    required this.surahNumber,
    required this.surahName,
    required this.lines,
  });

  Map<String, dynamic> toJson() => {
    'pageNumber': pageNumber,
    'juzNumber': juzNumber,
    'surahNumber': surahNumber,
    'surahName': surahName,
    'lines': lines.map((l) => l.toJson()).toList(),
  };

  factory Mushaf16LinePage.fromJson(Map<String, dynamic> json) {
    return Mushaf16LinePage(
      pageNumber: json['pageNumber'] as int? ?? 1,
      juzNumber: json['juzNumber'] as int? ?? 1,
      surahNumber: json['surahNumber'] as int? ?? 1,
      surahName: json['surahName'] as String? ?? 'Al-Fatihah',
      lines: (json['lines'] as List? ?? [])
          .map((l) => Mushaf16Line.fromJson(l as Map<String, dynamic>))
          .toList(),
    );
  }
}
