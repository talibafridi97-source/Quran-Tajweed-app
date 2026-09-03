import '../models/ayah.dart';
import '../models/surah.dart';
import '../models/mushaf_16_line_model.dart';

/// Service responsible for building deterministic 30-Para 16-line Quran Mushaf pages.
/// Follows standard Pakistani/Indo-Pak 16-line Mushaf pagination (typically 549 pages total).
/// - Page 2: Surah Al-Fatihah
/// - Page 3: Surah Al-Baqarah (Alif-Lam-Meem)
/// - Strictly enforces exactly 16 horizontal lines per page.
class Mushaf16LineLayoutService {
  static final Mushaf16LineLayoutService _instance = Mushaf16LineLayoutService._internal();
  factory Mushaf16LineLayoutService() => _instance;
  Mushaf16LineLayoutService._internal();

  static Mushaf16LineLayoutService get instance => _instance;

  final Map<int, Mushaf16LinePage> _pageCache = {};
  final Map<int, int> _surahStartPageMap = {};
  final Map<int, int> _juzStartPageMap = {};
  final Map<String, int> _ayahToPageMap = {};
  List<Mushaf16LinePage>? _allPagesCache;
  bool _isBuilt = false;

  bool get isReady => _isBuilt && _allPagesCache != null && _allPagesCache!.isNotEmpty;
  int get totalPages => _allPagesCache?.length ?? 549;

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
      // Skip non-spacing Arabic diacritics
      if (!((cu >= 0x0610 && cu <= 0x061A) ||
          (cu >= 0x064B && cu <= 0x065F) ||
          cu == 0x0670 ||
          (cu >= 0x06D6 && cu <= 0x06DC) ||
          (cu >= 0x06DF && cu <= 0x06E4) ||
          (cu >= 0x06E7 && cu <= 0x06E8) ||
          (cu >= 0x06EA && cu <= 0x06ED))) {
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
    _ayahToPageMap.clear();

    final List<Mushaf16LinePage> pages = [];
    final Map<int, List<Ayah>> ayahsBySurah = {};
    for (final ayah in allAyahs) {
      final sNum = ayah.surahNumber ?? 1;
      ayahsBySurah.putIfAbsent(sNum, () => []).add(ayah);
    }

    for (final sNum in ayahsBySurah.keys) {
      ayahsBySurah[sNum]!.sort((a, b) => a.numberInSurah.compareTo(b.numberInSurah));
    }

    // Page 1: Placeholder/Title
    pages.add(Mushaf16LinePage(pageNumber: 1, juzNumber: 1, surahNumber: 1, surahName: 'Title', lines: List.generate(16, (i) => Mushaf16Line(lineNumber: i+1, surahNumber: 1, surahName: 'Title', type: MushafLineType.empty))));

    // Page 2: Surah Al-Fatihah (7 Ayahs)
    _surahStartPageMap[1] = 2;
    _juzStartPageMap[1] = 2;
    final fatihahAyahs = ayahsBySurah[1] ?? [];
    final List<Mushaf16Line> p2Lines = [];
    p2Lines.add(Mushaf16Line(lineNumber: 1, type: MushafLineType.surahHeader, surahNumber: 1, surahName: 'Al-Fatihah'));
    p2Lines.add(Mushaf16Line(lineNumber: 2, type: MushafLineType.bismillah, surahNumber: 1, surahName: 'Al-Fatihah', juzNumber: 1));
    
    final List<MushafLineSegment> fSegs = [];
    for (var a in fatihahAyahs) {
      var words = a.text.replaceAll('\uFEFF', '').trim().split(RegExp(r'\s+'));
      for (var w in words) {
        if (w.isEmpty) continue;
        fSegs.add(MushafLineSegment(text: w, surahNumber: 1, ayahNumberInSurah: a.numberInSurah, verseKey: '1:${a.numberInSurah}'));
      }
      fSegs.add(MushafLineSegment(text: ' ﴿${toArabicDigits(a.numberInSurah)}﴾ ', surahNumber: 1, ayahNumberInSurah: a.numberInSurah, verseKey: '1:${a.numberInSurah}', isAyahEnd: true, ayahNumber: a.numberInSurah));
    }
    
    int fIdx = 0;
    for (int i = 3; i <= 10; i++) {
      int take = (fSegs.length / 8).ceil();
      if (fIdx < fSegs.length) {
        var lineSegs = fSegs.sublist(fIdx, (fIdx + take).clamp(0, fSegs.length));
        p2Lines.add(Mushaf16Line(lineNumber: i, type: MushafLineType.text, surahNumber: 1, surahName: 'Al-Fatihah', segments: lineSegs, ayahNumbers: [1,2,3,4,5,6,7], juzNumber: 1));
        fIdx += take;
      }
    }
    while (p2Lines.length < 16) p2Lines.add(Mushaf16Line(lineNumber: p2Lines.length + 1, type: MushafLineType.empty, surahNumber: 1, surahName: 'Al-Fatihah', juzNumber: 1));
    pages.add(Mushaf16LinePage(pageNumber: 2, juzNumber: 1, surahNumber: 1, surahName: 'Al-Fatihah', lines: p2Lines));

    // Page 3: Surah Al-Baqarah Start (Ayahs 1-5)
    _surahStartPageMap[2] = 3;
    final baqarahAyahs = ayahsBySurah[2] ?? [];
    final List<Mushaf16Line> p3Lines = [];
    p3Lines.add(Mushaf16Line(lineNumber: 1, type: MushafLineType.surahHeader, surahNumber: 2, surahName: 'Al-Baqarah'));
    p3Lines.add(Mushaf16Line(lineNumber: 2, type: MushafLineType.bismillah, surahNumber: 2, surahName: 'Al-Baqarah', juzNumber: 1));
    
    final List<MushafLineSegment> bSegs = [];
    for (var a in baqarahAyahs.where((a) => a.numberInSurah <= 5)) {
      var words = a.text.replaceAll('\uFEFF', '').trim().split(RegExp(r'\s+'));
      for (var w in words) {
        if (w.isEmpty) continue;
        bSegs.add(MushafLineSegment(text: w, surahNumber: 2, ayahNumberInSurah: a.numberInSurah, verseKey: '2:${a.numberInSurah}'));
      }
      bSegs.add(MushafLineSegment(text: ' ﴿${toArabicDigits(a.numberInSurah)}﴾ ', surahNumber: 2, ayahNumberInSurah: a.numberInSurah, verseKey: '2:${a.numberInSurah}', isAyahEnd: true, ayahNumber: a.numberInSurah));
    }
    
    int bIdx = 0;
    for (int i = 3; i <= 10; i++) {
      int take = (bSegs.length / 8).ceil();
      if (bIdx < bSegs.length) {
        var lineSegs = bSegs.sublist(bIdx, (bIdx + take).clamp(0, bSegs.length));
        p3Lines.add(Mushaf16Line(lineNumber: i, type: MushafLineType.text, surahNumber: 2, surahName: 'Al-Baqarah', segments: lineSegs, ayahNumbers: [1,2,3,4,5], juzNumber: 1));
        bIdx += take;
      }
    }
    while (p3Lines.length < 16) p3Lines.add(Mushaf16Line(lineNumber: p3Lines.length + 1, type: MushafLineType.empty, surahNumber: 2, surahName: 'Al-Baqarah', juzNumber: 1));
    pages.add(Mushaf16LinePage(pageNumber: 3, juzNumber: 1, surahNumber: 2, surahName: 'Al-Baqarah', lines: p3Lines));

    // Continuous flow from Page 4
    int currentPageNumber = 4;
    int currentJuzNumber = 1;
    int lastAddedJuz = 0;
    List<Mushaf16Line> currentLines = [];
    List<MushafLineSegment> currentLineSegments = [];
    Set<int> currentLineAyahs = {};
    int currentLen = 0;
    const int capacity = 38;

    void finalizePage() {
      if (currentLines.isEmpty) return;
      while (currentLines.length < 16) {
        currentLines.add(Mushaf16Line(lineNumber: currentLines.length + 1, type: MushafLineType.empty, surahNumber: currentLines.last.surahNumber, surahName: currentLines.last.surahName, juzNumber: currentJuzNumber));
      }
      final page = Mushaf16LinePage(pageNumber: currentPageNumber, juzNumber: currentJuzNumber, surahNumber: currentLines.first.surahNumber, surahName: currentLines.first.surahName, lines: List.from(currentLines));
      pages.add(page);
      _pageCache[page.pageNumber] = page;
      currentPageNumber++;
      currentLines.clear();
    }

    void flushLine(int sNum, String sName) {
      if (currentLineSegments.isNotEmpty) {
        final isParaStart = (lastAddedJuz < currentJuzNumber);
        if (isParaStart) lastAddedJuz = currentJuzNumber;

        currentLines.add(Mushaf16Line(
          lineNumber: currentLines.length + 1,
          type: MushafLineType.text,
          surahNumber: sNum,
          surahName: sName,
          segments: List.from(currentLineSegments),
          ayahNumbers: currentLineAyahs.toList()..sort(),
          isParaStart: isParaStart,
          juzNumber: currentJuzNumber,
        ));
        currentLineSegments.clear();
        currentLineAyahs.clear();
        currentLen = 0;
        if (currentLines.length == 16) finalizePage();
      }
    }

    for (var s in surahs) {
      if (s.number == 1) continue;
      final fullS = ayahsBySurah[s.number] ?? [];
      var sAyahs = s.number == 2 ? fullS.where((a) => a.numberInSurah > 5).toList() : fullS;
      
      if (s.number > 2) {
        _surahStartPageMap[s.number] = currentPageNumber;
        flushLine(s.number, s.englishName);
        if (currentLines.length >= 15) finalizePage();
        currentLines.add(Mushaf16Line(lineNumber: currentLines.length+1, type: MushafLineType.surahHeader, surahNumber: s.number, surahName: s.englishName, juzNumber: currentJuzNumber));
        if (s.number != 9) currentLines.add(Mushaf16Line(lineNumber: currentLines.length+1, type: MushafLineType.bismillah, surahNumber: s.number, surahName: s.englishName, juzNumber: currentJuzNumber));
        if (currentLines.length == 16) finalizePage();
      }

      for (var a in sAyahs) {
        if (a.juz > 0 && !_juzStartPageMap.containsKey(a.juz)) _juzStartPageMap[a.juz] = currentPageNumber;
        currentJuzNumber = a.juz;
        var words = a.text.replaceAll('\uFEFF', '').trim().split(RegExp(r'\s+'));
        for (var w in words) {
          if (w.isEmpty) continue;
          int wLen = _getVisualLength(w);
          if (currentLineSegments.isNotEmpty && (currentLen + wLen + 1 > capacity)) flushLine(s.number, s.englishName);
          currentLineSegments.add(MushafLineSegment(text: w, surahNumber: s.number, ayahNumberInSurah: a.numberInSurah, verseKey: '${s.number}:${a.numberInSurah}'));
          currentLineAyahs.add(a.numberInSurah);
          currentLen += wLen + 1;
        }
        var end = ' ﴿${toArabicDigits(a.numberInSurah)}﴾ ';
        if (currentLen + _getVisualLength(end) > capacity + 4) flushLine(s.number, s.englishName);
        currentLineSegments.add(MushafLineSegment(text: end, surahNumber: s.number, ayahNumberInSurah: a.numberInSurah, verseKey: '${s.number}:${a.numberInSurah}', isAyahEnd: true, ayahNumber: a.numberInSurah));
        currentLineAyahs.add(a.numberInSurah);
        currentLen += _getVisualLength(end);
      }
    }
    flushLine(114, 'An-Nas');
    finalizePage();

    _allPagesCache = pages;
    for (var p in pages) {
      _pageCache[p.pageNumber] = p;
      for (var l in p.lines) {
        for (var aNum in l.ayahNumbers) _ayahToPageMap['${l.surahNumber}:$aNum'] = p.pageNumber;
      }
    }
    _isBuilt = true;
    return pages;
  }

  int getSurahStartPage(int s) => _surahStartPageMap[s] ?? 1;
  int getJuzStartPage(int j) => _juzStartPageMap[j] ?? 1;
  Mushaf16LinePage? getPage(int p) => _pageCache[p];
  int? getPageForAyah(int s, int a) => _ayahToPageMap['$s:$a'];

  void clearCache() {
    _pageCache.clear();
    _surahStartPageMap.clear();
    _juzStartPageMap.clear();
    _ayahToPageMap.clear();
    _allPagesCache = null;
    _isBuilt = false;
  }
}
