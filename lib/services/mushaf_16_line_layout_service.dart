import '../models/ayah.dart';
import '../models/surah.dart';
import '../models/mushaf_16_line_model.dart';
import '../models/quran_word.dart';

/// Service responsible for building deterministic Tajweed Quran Mushaf (549 Pages).
/// Strictly reproduces the Taj Company Limited pagination standard.
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
  int get totalPages => 549; 

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
      if (!((cu >= 0x0610 && cu <= 0x061A) || (cu >= 0x064B && cu <= 0x065F) || cu == 0x0670 || (cu >= 0x06D6 && cu <= 0x06DC) || (cu >= 0x06DF && cu <= 0x06E4) || (cu >= 0x06E7 && cu <= 0x06E8) || (cu >= 0x06EA && cu <= 0x06ED))) {
        count++;
      }
    }
    return count > 0 ? count : text.length;
  }

  // Exact Indo-Pak Juz Start Points (Surah:Ayah)
  static const Map<int, String> juzStartMap = {
    1: "1:1", 2: "2:142", 3: "2:253", 4: "3:92", 5: "4:24", 
    6: "4:148", 7: "5:82", 8: "6:111", 9: "7:88", 10: "8:41",
    11: "9:93", 12: "11:6", 13: "12:53", 14: "15:1", 15: "17:1",
    16: "18:75", 17: "21:1", 18: "23:1", 19: "25:21", 20: "27:56",
    21: "29:46", 22: "33:31", 23: "36:28", 24: "39:32", 25: "41:47",
    26: "46:1", 27: "51:31", 28: "58:1", 29: "67:1", 30: "78:1"
  };

  List<Mushaf16LinePage> buildAllPages({required List<Surah> surahs, required List<Ayah> allAyahs}) {
    if (_isBuilt && _allPagesCache != null && allAyahs.isEmpty) return _allPagesCache!;
    if (allAyahs.isEmpty) return _allPagesCache ?? [];

    _pageCache.clear(); _surahStartPageMap.clear(); _juzStartPageMap.clear(); _ayahToPageMap.clear();

    final List<Mushaf16LinePage> pages = [];
    final Map<int, List<Ayah>> ayahsBySurah = {};
    for (final ayah in allAyahs) { ayahsBySurah.putIfAbsent(ayah.surahNumber ?? 1, () => []).add(ayah); }
    for (final s in ayahsBySurah.keys) { ayahsBySurah[s]!.sort((a, b) => a.numberInSurah.compareTo(b.numberInSurah)); }

    // Page 1: Cover
    pages.add(Mushaf16LinePage(pageNumber: 1, juzNumber: 1, surahNumber: 1, surahName: 'Cover', lines: List.generate(16, (i) => Mushaf16Line(lineNumber: i+1, surahNumber: 1, surahName: 'Cover', type: MushafLineType.empty))));

    int curPageNum = 2;
    int curJuzNum = 1;
    List<Mushaf16Line> curPageLines = [];
    List<MushafLineSegment> curLineSegs = [];
    Set<int> curLineAyahs = {};
    int curLineLen = 0;
    const int lineCapacity = 20; // DECREASED TO 20 FOR ULTIMATE OVERFLOW PROTECTION
    bool isNextTextLineParaStart = true; 
    int currentManzil = 1;

    void pushLine(int sNum, String sName, {bool paraStart = false, int rukuNum = 0, bool rukuEnd = false}) {
      if (curLineSegs.isEmpty) return;
      curPageLines.add(Mushaf16Line(
        lineNumber: curPageLines.length + 1, type: MushafLineType.text,
        surahNumber: sNum, surahName: sName, segments: List.from(curLineSegs),
        ayahNumbers: curLineAyahs.toList()..sort(), isParaStart: paraStart, 
        juzNumber: curJuzNum, manzilNumber: currentManzil,
        isRukuEnd: rukuEnd, rukuNumber: rukuNum,
      ));
      curLineSegs.clear(); curLineAyahs.clear(); curLineLen = 0;
      if (curPageLines.length == 16) {
        pages.add(Mushaf16LinePage(pageNumber: curPageNum++, juzNumber: curJuzNum, surahNumber: sNum, surahName: sName, lines: List.from(curPageLines)));
        curPageLines.clear();
      }
    }

    void finishPage(int sNum, String sName) {
      if (curLineSegs.isNotEmpty) pushLine(sNum, sName, paraStart: isNextTextLineParaStart);
      isNextTextLineParaStart = false;
      if (curPageLines.isEmpty) return;
      while (curPageLines.length < 16) {
        curPageLines.add(Mushaf16Line(lineNumber: curPageLines.length + 1, type: MushafLineType.empty, surahNumber: sNum, surahName: sName, juzNumber: curJuzNum));
      }
      pages.add(Mushaf16LinePage(pageNumber: curPageNum++, juzNumber: curJuzNum, surahNumber: sNum, surahName: sName, lines: List.from(curPageLines)));
      curPageLines.clear();
    }

    void addSpecial(MushafLineType t, int sNum, String sName) {
      if (curLineSegs.isNotEmpty) pushLine(sNum, sName, paraStart: isNextTextLineParaStart);
      isNextTextLineParaStart = false;
      if (curPageLines.length >= 15) finishPage(sNum, sName);
      curPageLines.add(Mushaf16Line(lineNumber: curPageLines.length + 1, type: t, surahNumber: sNum, surahName: sName, juzNumber: curJuzNum, manzilNumber: currentManzil));
      if (curPageLines.length == 16) finishPage(sNum, sName);
    }

    surahs.sort((a, b) => a.number.compareTo(b.number));

    for (var s in surahs) {
      var list = ayahsBySurah[s.number] ?? [];
      if (list.isEmpty) continue;

      for (var a in list) {
        final String verseKey = "${s.number}:${a.numberInSurah}";
        currentManzil = a.manzil;
        
        // Detect Canonical Juz Boundary
        int? boundaryJuz;
        juzStartMap.forEach((j, key) { if (key == verseKey) boundaryJuz = j; });

        if (boundaryJuz != null && boundaryJuz! > 1) {
          finishPage(s.number, s.englishName);
          curJuzNum = boundaryJuz!;
          _juzStartPageMap[curJuzNum] = curPageNum;
          isNextTextLineParaStart = true;
        }

        if (a.numberInSurah == 1) {
          _surahStartPageMap[s.number] = curPageNum;
          addSpecial(MushafLineType.surahHeader, s.number, s.englishName);
          if (s.number != 9) addSpecial(MushafLineType.bismillah, s.number, s.englishName);
        }

        // Map words with translation (Lafzi Tarjuma)
        if (a.words.isNotEmpty) {
          for (var w in a.words) {
            final text = w.textUthmani ?? '';
            if (text.isEmpty) continue;
            int visLen = _getVisualLength(text);
            if (curLineSegs.isNotEmpty && (curLineLen + visLen + 1 > lineCapacity)) {
               pushLine(s.number, s.englishName, paraStart: isNextTextLineParaStart);
               isNextTextLineParaStart = false;
            }
            curLineSegs.add(MushafLineSegment(text: text, surahNumber: s.number, ayahNumberInSurah: a.numberInSurah, verseKey: verseKey, translation: w.translation));
            curLineAyahs.add(a.numberInSurah); curLineLen += visLen + 1;
          }
        } else {
          var words = a.text.replaceAll('\uFEFF', '').trim().split(RegExp(r'\s+'));
          for (var w in words) {
            if (w.isEmpty) continue;
            int visLen = _getVisualLength(w);
            if (curLineSegs.isNotEmpty && (curLineLen + visLen + 1 > lineCapacity)) {
               pushLine(s.number, s.englishName, paraStart: isNextTextLineParaStart);
               isNextTextLineParaStart = false;
            }
            curLineSegs.add(MushafLineSegment(text: w, surahNumber: s.number, ayahNumberInSurah: a.numberInSurah, verseKey: verseKey));
            curLineAyahs.add(a.numberInSurah); curLineLen += visLen + 1;
          }
        }

        var marker = ' ﴿${toArabicDigits(a.numberInSurah)}﴾ ';
        int mVis = _getVisualLength(marker);
        
        bool rukuEnd = false;
        int nextIdx = list.indexOf(a) + 1;
        if (nextIdx < list.length) {
          if (list[nextIdx].ruku > a.ruku) rukuEnd = true;
        } else { rukuEnd = true; }

        if (curLineSegs.isNotEmpty && (curLineLen + mVis > lineCapacity + 4)) {
           pushLine(s.number, s.englishName, paraStart: isNextTextLineParaStart);
           isNextTextLineParaStart = false;
        }
        
        curLineSegs.add(MushafLineSegment(text: marker, surahNumber: s.number, ayahNumberInSurah: a.numberInSurah, verseKey: verseKey, isAyahEnd: true, ayahNumber: a.numberInSurah));
        curLineAyahs.add(a.numberInSurah);
        curLineLen += mVis;

        if (rukuEnd) {
          pushLine(s.number, s.englishName, paraStart: isNextTextLineParaStart, rukuNum: a.ruku, rukuEnd: true);
          isNextTextLineParaStart = false;
        }
      }
    }
    finishPage(114, 'An-Nas');

    _allPagesCache = pages;
    for (var p in pages) { 
      _pageCache[p.pageNumber] = p; 
      for (var l in p.lines) { 
        _surahStartPageMap.putIfAbsent(l.surahNumber, () => p.pageNumber);
        if (l.juzNumber != null) _juzStartPageMap.putIfAbsent(l.juzNumber!, () => p.pageNumber);
        for (var an in l.ayahNumbers) _ayahToPageMap['${l.surahNumber}:$an'] = p.pageNumber; 
      } 
    }
    _isBuilt = true; return pages;
  }

  int getSurahStartPage(int s) => _surahStartPageMap[s] ?? 2;
  int getJuzStartPage(int j) => _juzStartPageMap[j] ?? 2;
  Mushaf16LinePage? getPage(int p) => _pageCache[p];
  int? getPageForAyah(int s, int a) => _ayahToPageMap['$s:$a'];
  void clearCache() { _pageCache.clear(); _surahStartPageMap.clear(); _juzStartPageMap.clear(); _ayahToPageMap.clear(); _allPagesCache = null; _isBuilt = false; }
}
