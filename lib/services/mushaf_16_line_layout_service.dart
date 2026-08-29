import '../models/ayah.dart';
import '../models/surah.dart';
import '../models/mushaf_16_line_model.dart';

/// Service responsible for building deterministic 30-Para 16-line Quran Mushaf pages
/// from canonical Quran text according to standard Indo-Pak / Madani pagination rules:
/// - Page 1: Dedicated Surah Al-Fatihah (Ayahs 1-7, Alhamdulillah to Waladwaleen)
/// - Page 2: Dedicated Surah Al-Baqarah Opening (Ayahs 1-4, Alif-Lam-Meem to Yooqinoon)
/// - Pages 3..End: Standardized continuous 16-line layout with exactly 16 line slots per page.
class Mushaf16LineLayoutService {
  static final Mushaf16LineLayoutService _instance = Mushaf16LineLayoutService._internal();
  factory Mushaf16LineLayoutService() => _instance;
  Mushaf16LineLayoutService._internal();

  static Mushaf16LineLayoutService get instance => _instance;

  final Map<int, Mushaf16LinePage> _pageCache = {};
  final Map<int, int> _surahStartPageMap = {};
  final Map<int, int> _juzStartPageMap = {};
  List<Mushaf16LinePage>? _allPagesCache;
  bool _isBuilt = false;

  bool get isReady => _isBuilt && _allPagesCache != null && _allPagesCache!.isNotEmpty;
  int get totalPages => _allPagesCache?.length ?? 811;

  static String toArabicDigits(int number) {
    const arabicDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    return number.toString().split('').map((digit) {
      final idx = int.tryParse(digit);
      return idx != null ? arabicDigits[idx] : digit;
    }).join();
  }

  static int _getVisualLength(String text) {
    int count = 0;
    for (int i = 0; i < text.length; i++) {
      int cu = text.codeUnitAt(i);
      if (!((cu >= 0x0610 && cu <= 0x061A) ||
          (cu >= 0x064B && cu <= 0x065F) ||
          cu == 0x0670 ||
          (cu >= 0x06D6 && cu <= 0x06DC) ||
          (cu >= 0x06DF && cu <= 0x06E4) ||
          (cu >= 0x06E7 && cu <= 0x06E8) ||
          (cu >= 0x06EA && cu <= 0x06ED) ||
          (cu >= 0x08D4 && cu <= 0x08E1) ||
          (cu >= 0x08E3 && cu <= 0x08FF))) {
        count++;
      }
    }
    return count > 0 ? count : text.length;
  }

  List<Mushaf16LinePage> buildAllPages({
    required List<Surah> surahs,
    required List<Ayah> allAyahs,
  }) {
    if (_allPagesCache != null && _allPagesCache!.isNotEmpty && allAyahs.isEmpty) {
      return _allPagesCache!;
    }

    _pageCache.clear();
    _surahStartPageMap.clear();
    _juzStartPageMap.clear();

    final List<Mushaf16LinePage> pages = [];
    final Map<int, List<Ayah>> ayahsBySurah = {};
    for (final ayah in allAyahs) {
      final sNum = ayah.surahNumber ?? 1;
      ayahsBySurah.putIfAbsent(sNum, () => []).add(ayah);
    }

    for (final sNum in ayahsBySurah.keys) {
      ayahsBySurah[sNum]!.sort((a, b) => a.numberInSurah.compareTo(b.numberInSurah));
    }

    // -------------------------------------------------------------
    // PAGE 1: Dedicated Surah Al-Fatihah Page (Ayahs 1 to 7)
    // -------------------------------------------------------------
    _surahStartPageMap[1] = 1;
    _juzStartPageMap[1] = 1;
    final fatihahAyahs = ayahsBySurah[1] ?? [];
    final List<Mushaf16Line> p1Lines = [];
    p1Lines.add(Mushaf16Line(lineNumber: 1, type: MushafLineType.surahHeader, surahNumber: 1, surahName: 'Al-Fatihah'));
    p1Lines.add(Mushaf16Line(lineNumber: 2, type: MushafLineType.bismillah, surahNumber: 1, surahName: 'Al-Fatihah'));
    
    final List<MushafLineSegment> fSegs = [];
    for (var a in fatihahAyahs) {
      final words = a.text.replaceAll('\uFEFF', '').trim().split(RegExp(r'\s+'));
      for (var w in words) {
        if (w.isNotEmpty) {
          fSegs.add(MushafLineSegment(text: w, surahNumber: 1, ayahNumberInSurah: a.numberInSurah, verseKey: '1:${a.numberInSurah}'));
        }
      }
      fSegs.add(MushafLineSegment(text: ' ﴿${toArabicDigits(a.numberInSurah)}﴾ ', surahNumber: 1, ayahNumberInSurah: a.numberInSurah, verseKey: '1:${a.numberInSurah}', isAyahEnd: true, ayahNumber: a.numberInSurah));
    }
    
    int fIdx = 0;
    for (int i = 3; i <= 10; i++) {
      int take = (fSegs.length / 8).ceil();
      if (fIdx < fSegs.length) {
        var lineSegs = fSegs.sublist(fIdx, (fIdx + take).clamp(0, fSegs.length));
        p1Lines.add(Mushaf16Line(lineNumber: i, type: MushafLineType.text, surahNumber: 1, surahName: 'Al-Fatihah', segments: lineSegs, ayahNumbers: [1,2,3,4,5,6,7]));
        fIdx += take;
      }
    }
    while (p1Lines.length < 16) {
      p1Lines.add(Mushaf16Line(lineNumber: p1Lines.length + 1, type: MushafLineType.empty, surahNumber: 1, surahName: 'Al-Fatihah'));
    }
    pages.add(Mushaf16LinePage(pageNumber: 1, juzNumber: 1, surahNumber: 1, surahName: 'Al-Fatihah', lines: p1Lines));

    // -------------------------------------------------------------
    // PAGE 2: Dedicated Surah Al-Baqarah Opening (Ayahs 1 to 4)
    // -------------------------------------------------------------
    _surahStartPageMap[2] = 2;
    final baqarahAyahs = ayahsBySurah[2] ?? [];
    final List<Mushaf16Line> p2Lines = [];
    p2Lines.add(Mushaf16Line(lineNumber: 1, type: MushafLineType.surahHeader, surahNumber: 2, surahName: 'Al-Baqarah'));
    p2Lines.add(Mushaf16Line(lineNumber: 2, type: MushafLineType.bismillah, surahNumber: 2, surahName: 'Al-Baqarah'));
    
    final List<MushafLineSegment> bSegs = [];
    for (var a in baqarahAyahs.where((a) => a.numberInSurah >= 1 && a.numberInSurah <= 4)) {
      final words = a.text.replaceAll('\uFEFF', '').trim().split(RegExp(r'\s+'));
      for (var w in words) {
        if (w.isNotEmpty) {
          bSegs.add(MushafLineSegment(text: w, surahNumber: 2, ayahNumberInSurah: a.numberInSurah, verseKey: '2:${a.numberInSurah}'));
        }
      }
      bSegs.add(MushafLineSegment(text: ' ﴿${toArabicDigits(a.numberInSurah)}﴾ ', surahNumber: 2, ayahNumberInSurah: a.numberInSurah, verseKey: '2:${a.numberInSurah}', isAyahEnd: true, ayahNumber: a.numberInSurah));
    }
    
    int bIdx = 0;
    for (int i = 3; i <= 10; i++) {
      int take = (bSegs.length / 8).ceil();
      if (bIdx < bSegs.length) {
        var lineSegs = bSegs.sublist(bIdx, (bIdx + take).clamp(0, bSegs.length));
        p2Lines.add(Mushaf16Line(lineNumber: i, type: MushafLineType.text, surahNumber: 2, surahName: 'Al-Baqarah', segments: lineSegs, ayahNumbers: [1,2,3,4]));
        bIdx += take;
      }
    }
    while (p2Lines.length < 16) {
      p2Lines.add(Mushaf16Line(lineNumber: p2Lines.length + 1, type: MushafLineType.empty, surahNumber: 2, surahName: 'Al-Baqarah'));
    }
    pages.add(Mushaf16LinePage(pageNumber: 2, juzNumber: 1, surahNumber: 2, surahName: 'Al-Baqarah', lines: p2Lines));

    // -------------------------------------------------------------
    // PAGES 3 UNTIL THE END: Continuous Standardized 16-Line Layout
    // Starts from Surah 2 Ayah 5 through Surah 114 Ayah 6
    // -------------------------------------------------------------
    int currentPageNumber = 3;
    int currentJuzNumber = 1;
    List<Mushaf16Line> currentLines = [];
    List<MushafLineSegment> currentLineSegments = [];
    Set<int> currentLineAyahs = {};
    int currentLen = 0;
    const int capacity = 38;

    void flushLine(int sNum, String sName) {
      if (currentLineSegments.isNotEmpty) {
        currentLines.add(Mushaf16Line(
          lineNumber: currentLines.length + 1,
          type: MushafLineType.text,
          surahNumber: sNum,
          surahName: sName,
          segments: List.from(currentLineSegments),
          ayahNumbers: currentLineAyahs.toList()..sort(),
        ));
        currentLineSegments.clear();
        currentLineAyahs.clear();
        currentLen = 0;
        if (currentLines.length == 16) {
          pages.add(Mushaf16LinePage(
            pageNumber: currentPageNumber++,
            juzNumber: currentJuzNumber,
            surahNumber: sNum,
            surahName: sName,
            lines: List.from(currentLines),
          ));
          currentLines.clear();
        }
      }
    }

    for (var s in surahs) {
      if (s.number == 1) continue;
      var ayahs = ayahsBySurah[s.number] ?? [];
      if (s.number == 2) {
        ayahs = ayahs.where((a) => a.numberInSurah >= 5).toList();
      } else {
        flushLine(s.number, s.englishName);
        if (currentLines.length >= 14) {
          while (currentLines.length < 16) {
            currentLines.add(Mushaf16Line(
              lineNumber: currentLines.length + 1,
              type: MushafLineType.empty,
              surahNumber: s.number,
              surahName: s.englishName,
            ));
          }
          pages.add(Mushaf16LinePage(
            pageNumber: currentPageNumber++,
            juzNumber: currentJuzNumber,
            surahNumber: s.number,
            surahName: s.englishName,
            lines: List.from(currentLines),
          ));
          currentLines.clear();
        }
        _surahStartPageMap[s.number] = currentPageNumber;
        currentLines.add(Mushaf16Line(
          lineNumber: currentLines.length + 1,
          type: MushafLineType.surahHeader,
          surahNumber: s.number,
          surahName: s.englishName,
        ));
        if (s.number != 9) {
          currentLines.add(Mushaf16Line(
            lineNumber: currentLines.length + 1,
            type: MushafLineType.bismillah,
            surahNumber: s.number,
            surahName: s.englishName,
          ));
        }
      }

      for (var a in ayahs) {
        if (a.juz > 0 && !_juzStartPageMap.containsKey(a.juz)) {
          _juzStartPageMap[a.juz] = currentPageNumber;
        }
        if (a.juz > 0) currentJuzNumber = a.juz;

        var words = a.text.replaceAll('\uFEFF', '').trim().split(RegExp(r'\s+'));
        for (var w in words) {
          if (w.isEmpty) continue;
          int wLen = _getVisualLength(w);
          if (currentLineSegments.isNotEmpty && (currentLen + wLen + 1 > capacity)) {
            flushLine(s.number, s.englishName);
          }
          currentLineSegments.add(MushafLineSegment(
            text: w,
            surahNumber: s.number,
            ayahNumberInSurah: a.numberInSurah,
            verseKey: '${s.number}:${a.numberInSurah}',
          ));
          currentLineAyahs.add(a.numberInSurah);
          currentLen += wLen + 1;
        }
        var end = ' ﴿${toArabicDigits(a.numberInSurah)}﴾ ';
        int endLen = _getVisualLength(end);
        if (currentLineSegments.isNotEmpty && (currentLen + endLen > capacity + 4)) {
          flushLine(s.number, s.englishName);
        }
        currentLineSegments.add(MushafLineSegment(
          text: end,
          surahNumber: s.number,
          ayahNumberInSurah: a.numberInSurah,
          verseKey: '${s.number}:${a.numberInSurah}',
          isAyahEnd: true,
          ayahNumber: a.numberInSurah,
        ));
        currentLineAyahs.add(a.numberInSurah);
        currentLen += endLen;
      }
    }
    flushLine(114, 'An-Nas');
    if (currentLines.isNotEmpty) {
      while (currentLines.length < 16) {
        currentLines.add(Mushaf16Line(
          lineNumber: currentLines.length + 1,
          type: MushafLineType.empty,
          surahNumber: 114,
          surahName: 'An-Nas',
        ));
      }
      pages.add(Mushaf16LinePage(
        pageNumber: currentPageNumber,
        juzNumber: 30,
        surahNumber: 114,
        surahName: 'An-Nas',
        lines: currentLines,
      ));
    }

    _allPagesCache = pages;
    for (var p in pages) {
      _pageCache[p.pageNumber] = p;
    }
    _isBuilt = true;
    return pages;
  }

  int getSurahStartPage(int sNum) => _surahStartPageMap[sNum] ?? 1;
  int getJuzStartPage(int jNum) => _juzStartPageMap[jNum] ?? 1;
  Mushaf16LinePage? getPage(int pNum) => _pageCache[pNum];
  void clearCache() {
    _pageCache.clear();
    _surahStartPageMap.clear();
    _juzStartPageMap.clear();
    _allPagesCache = null;
    _isBuilt = false;
  }
}
