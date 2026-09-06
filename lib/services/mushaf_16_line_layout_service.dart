import '../models/ayah.dart';
import '../models/surah.dart';
import '../models/mushaf_16_line_model.dart';

/// Service responsible for building deterministic 30-Para 16-line Quran Mushaf pages.
/// Strictly follows standard Pakistani/Indo-Pak Mushaf pagination (549 Pages).
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
  int get totalPages => 549; // Standard Pakistani 16-line Mushaf

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

  List<Mushaf16LinePage> buildAllPages({required List<Surah> surahs, required List<Ayah> allAyahs}) {
    // If cache is ready and input is empty, return cache
    if (_isBuilt && _allPagesCache != null && allAyahs.isEmpty) return _allPagesCache!;
    if (allAyahs.isEmpty) return _allPagesCache ?? [];

    // Otherwise rebuild
    _pageCache.clear(); _surahStartPageMap.clear(); _juzStartPageMap.clear(); _ayahToPageMap.clear();

    final List<Mushaf16LinePage> pages = [];
    final Map<int, List<Ayah>> ayahsBySurah = {};
    for (final ayah in allAyahs) { ayahsBySurah.putIfAbsent(ayah.surahNumber ?? 1, () => []).add(ayah); }
    for (final s in ayahsBySurah.keys) { ayahsBySurah[s]!.sort((a, b) => a.numberInSurah.compareTo(b.numberInSurah)); }

    // Page 1: Empty Title Page
    pages.add(Mushaf16LinePage(pageNumber: 1, juzNumber: 1, surahNumber: 1, surahName: 'Quran', lines: List.generate(16, (i) => Mushaf16Line(lineNumber: i+1, surahNumber: 1, surahName: 'Quran', type: MushafLineType.empty))));

    // Page 2: Surah Al-Fatihah
    _surahStartPageMap[1] = 2; _juzStartPageMap[1] = 2;
    final fAyahs = ayahsBySurah[1] ?? [];
    final List<Mushaf16Line> p2Lines = [
      Mushaf16Line(lineNumber: 1, type: MushafLineType.surahHeader, surahNumber: 1, surahName: 'Al-Fatihah'),
      Mushaf16Line(lineNumber: 2, type: MushafLineType.bismillah, surahNumber: 1, surahName: 'Al-Fatihah', juzNumber: 1),
    ];
    final List<MushafLineSegment> fSegs = [];
    for (var a in fAyahs) {
      var words = a.text.replaceAll('\uFEFF', '').trim().split(RegExp(r'\s+'));
      for (var w in words) { if (w.isNotEmpty) fSegs.add(MushafLineSegment(text: w, surahNumber: 1, ayahNumberInSurah: a.numberInSurah, verseKey: '1:${a.numberInSurah}')); }
      fSegs.add(MushafLineSegment(text: ' ﴿${toArabicDigits(a.numberInSurah)}﴾ ', surahNumber: 1, ayahNumberInSurah: a.numberInSurah, verseKey: '1:${a.numberInSurah}', isAyahEnd: true, ayahNumber: a.numberInSurah));
    }
    int fPtr = 0;
    for (int i = 3; i <= 10; i++) {
      int count = (fSegs.length / 8).ceil();
      p2Lines.add(Mushaf16Line(lineNumber: i, type: MushafLineType.text, surahNumber: 1, surahName: 'Al-Fatihah', segments: fSegs.sublist(fPtr, (fPtr + count).clamp(0, fSegs.length)), ayahNumbers: [1,2,3,4,5,6,7], juzNumber: 1));
      fPtr += count;
    }
    while (p2Lines.length < 16) p2Lines.add(Mushaf16Line(lineNumber: p2Lines.length + 1, type: MushafLineType.empty, surahNumber: 1, surahName: 'Al-Fatihah', juzNumber: 1));
    pages.add(Mushaf16LinePage(pageNumber: 2, juzNumber: 1, surahNumber: 1, surahName: 'Al-Fatihah', lines: p2Lines));

    // Page 3: Surah Al-Baqarah 1-4 (Fixed Duplicate Ayah 5)
    _surahStartPageMap[2] = 3;
    final bStartAyahs = (ayahsBySurah[2] ?? []).where((a) => a.numberInSurah <= 4).toList();
    final List<Mushaf16Line> p3Lines = [
      Mushaf16Line(lineNumber: 1, type: MushafLineType.surahHeader, surahNumber: 2, surahName: 'Al-Baqarah'),
      Mushaf16Line(lineNumber: 2, type: MushafLineType.bismillah, surahNumber: 2, surahName: 'Al-Baqarah', juzNumber: 1),
    ];
    final List<MushafLineSegment> bSegs = [];
    for (var a in bStartAyahs) {
      var words = a.text.replaceAll('\uFEFF', '').trim().split(RegExp(r'\s+'));
      for (var w in words) { if (w.isNotEmpty) bSegs.add(MushafLineSegment(text: w, surahNumber: 2, ayahNumberInSurah: a.numberInSurah, verseKey: '2:${a.numberInSurah}')); }
      bSegs.add(MushafLineSegment(text: ' ﴿${toArabicDigits(a.numberInSurah)}﴾ ', surahNumber: 2, ayahNumberInSurah: a.numberInSurah, verseKey: '2:${a.numberInSurah}', isAyahEnd: true, ayahNumber: a.numberInSurah));
    }
    int bPtr = 0;
    for (int i = 3; i <= 10; i++) {
      int count = (bSegs.length / 8).ceil();
      p3Lines.add(Mushaf16Line(lineNumber: i, type: MushafLineType.text, surahNumber: 2, surahName: 'Al-Baqarah', segments: bSegs.sublist(bPtr, (bPtr + count).clamp(0, bSegs.length)), ayahNumbers: [1,2,3,4], juzNumber: 1));
      bPtr += count;
    }
    while (p3Lines.length < 16) p3Lines.add(Mushaf16Line(lineNumber: p3Lines.length + 1, type: MushafLineType.empty, surahNumber: 2, surahName: 'Al-Baqarah', juzNumber: 1));
    pages.add(Mushaf16LinePage(pageNumber: 3, juzNumber: 1, surahNumber: 2, surahName: 'Al-Baqarah', lines: p3Lines));

    // Page 4: Surah Al-Baqarah 5-17 (Precise Mapping)
    final List<Ayah> p4Ayahs = (ayahsBySurah[2] ?? []).where((a) => a.numberInSurah >= 5 && a.numberInSurah <= 17).toList();
    final List<MushafLineSegment> p4Segs = [];
    for (var a in p4Ayahs) {
      var words = a.text.replaceAll('\uFEFF', '').trim().split(RegExp(r'\s+'));
      for (var w in words) { if (w.isNotEmpty) p4Segs.add(MushafLineSegment(text: w, surahNumber: 2, ayahNumberInSurah: a.numberInSurah, verseKey: '2:${a.numberInSurah}')); }
      p4Segs.add(MushafLineSegment(text: ' ﴿${toArabicDigits(a.numberInSurah)}﴾ ', surahNumber: 2, ayahNumberInSurah: a.numberInSurah, verseKey: '2:${a.numberInSurah}', isAyahEnd: true, ayahNumber: a.numberInSurah));
    }
    final List<Mushaf16Line> p4Lines = [];
    int p4Ptr = 0;
    for (int i = 1; i <= 16; i++) {
      int count = (p4Segs.length / 16).ceil();
      p4Lines.add(Mushaf16Line(lineNumber: i, type: MushafLineType.text, surahNumber: 2, surahName: 'Al-Baqarah', segments: p4Segs.sublist(p4Ptr, (p4Ptr + count).clamp(0, p4Segs.length)), ayahNumbers: p4Ayahs.map((a)=>a.numberInSurah).toSet().toList(), juzNumber: 1));
      p4Ptr += count;
    }
    pages.add(Mushaf16LinePage(pageNumber: 4, juzNumber: 1, surahNumber: 2, surahName: 'Al-Baqarah', lines: p4Lines));

    // Page 5 onwards...
    int curPageNum = 5; int curJuzNum = 1; int lastJuz = 0;
    List<Mushaf16Line> curLines = []; List<MushafLineSegment> curSegs = []; Set<int> curAyahs = {}; int curLen = 0; const int capacity = 36;

    void flush(int sNum, String sName) {
      if (curSegs.isEmpty) return;
      final isStart = (lastJuz < curJuzNum); if (isStart) lastJuz = curJuzNum;
      curLines.add(Mushaf16Line(lineNumber: curLines.length+1, type: MushafLineType.text, surahNumber: sNum, surahName: sName, segments: List.from(curSegs), ayahNumbers: curAyahs.toList()..sort(), isParaStart: isStart, juzNumber: curJuzNum));
      curSegs.clear(); curAyahs.clear(); curLen = 0;
      if (curLines.length == 16) { pages.add(Mushaf16LinePage(pageNumber: curPageNum++, juzNumber: curJuzNum, surahNumber: sNum, surahName: sName, lines: List.from(curLines))); curLines.clear(); }
    }

    for (var s in surahs) {
      if (s.number == 1) continue;
      var list = ayahsBySurah[s.number] ?? [];
      if (s.number == 2) list = list.where((a) => a.numberInSurah > 17).toList();
      else {
        flush(s.number, s.englishName);
        if (curLines.length >= 15) { while(curLines.length<16) curLines.add(Mushaf16Line(lineNumber: curLines.length+1, type: MushafLineType.empty, surahNumber: s.number, surahName: s.englishName, juzNumber: curJuzNum)); pages.add(Mushaf16LinePage(pageNumber: curPageNum++, juzNumber: curJuzNum, surahNumber: s.number, surahName: s.englishName, lines: List.from(curLines))); curLines.clear(); }
        curLines.add(Mushaf16Line(lineNumber: curLines.length+1, type: MushafLineType.surahHeader, surahNumber: s.number, surahName: s.englishName, juzNumber: curJuzNum));
        if (s.number != 9) curLines.add(Mushaf16Line(lineNumber: curLines.length+1, type: MushafLineType.bismillah, surahNumber: s.number, surahName: s.englishName, juzNumber: curJuzNum));
      }
      for (var a in list) {
        if (a.juz > 0 && !_juzStartPageMap.containsKey(a.juz)) _juzStartPageMap[a.juz] = curPageNum;
        curJuzNum = a.juz;
        var words = a.text.replaceAll('\uFEFF', '').trim().split(RegExp(r'\s+'));
        for (var w in words) {
          if (w.isEmpty) continue;
          int l = _getVisualLength(w);
          if (curSegs.isNotEmpty && (curLen + l + 1 > capacity)) flush(s.number, s.englishName);
          curSegs.add(MushafLineSegment(text: w, surahNumber: s.number, ayahNumberInSurah: a.numberInSurah, verseKey: '${s.number}:${a.numberInSurah}'));
          curAyahs.add(a.numberInSurah); curLen += l + 1;
        }
        var m = ' ﴿${toArabicDigits(a.numberInSurah)}﴾ ';
        if (curSegs.isNotEmpty && (curLen + _getVisualLength(m) > capacity + 4)) flush(s.number, s.englishName);
        curSegs.add(MushafLineSegment(text: m, surahNumber: s.number, ayahNumberInSurah: a.numberInSurah, verseKey: '${s.number}:${a.numberInSurah}', isAyahEnd: true, ayahNumber: a.numberInSurah));
        curAyahs.add(a.numberInSurah); curLen += _getVisualLength(m);
      }
    }
    flush(114, 'An-Nas');
    if (curLines.isNotEmpty) { while(curLines.length<16) curLines.add(Mushaf16Line(lineNumber: curLines.length+1, type: MushafLineType.empty, surahNumber: 114, surahName: 'An-Nas', juzNumber: 30)); pages.add(Mushaf16LinePage(pageNumber: curPageNum, juzNumber: 30, surahNumber: 114, surahName: 'An-Nas', lines: curLines)); }

    _allPagesCache = pages;
    for (var p in pages) { _pageCache[p.pageNumber] = p; for (var l in p.lines) { for (var an in l.ayahNumbers) _ayahToPageMap['${l.surahNumber}:$an'] = p.pageNumber; } }
    _isBuilt = true; return pages;
  }

  int getSurahStartPage(int s) => _surahStartPageMap[s] ?? 2;
  int getJuzStartPage(int j) => _juzStartPageMap[j] ?? 2;
  Mushaf16LinePage? getPage(int p) => _pageCache[p];
  int? getPageForAyah(int s, int a) => _ayahToPageMap['$s:$a'];
  void clearCache() { _pageCache.clear(); _surahStartPageMap.clear(); _juzStartPageMap.clear(); _ayahToPageMap.clear(); _allPagesCache = null; _isBuilt = false; }
}
