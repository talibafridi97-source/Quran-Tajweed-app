import '../models/surah.dart';
import '../models/ayah.dart';
import '../services/api_service.dart';
import '../services/local_storage_service.dart';
import '../services/database_service.dart';
import '../models/resume_data.dart';
import '../models/quran_word.dart';

class QuranRepository {
  final ApiService _apiService;
  final LocalStorageService _localStorageService;
  final DatabaseService _databaseService;

  QuranRepository(this._apiService, this._localStorageService, this._databaseService);

  Future<List<Surah>> getAllSurahs() async {
    final localSurahs = await _databaseService.getSurahs();
    if (localSurahs.isNotEmpty) return localSurahs;

    final apiSurahs = await _apiService.getAllSurahs();
    await _databaseService.saveSurahs(apiSurahs);
    return apiSurahs;
  }

  Future<List<Ayah>> getSurahTajweed(int chapterNumber) async {
    final localAyahs = await _databaseService.getAyahsForSurah(chapterNumber);
    if (localAyahs.isNotEmpty) return localAyahs;

    final apiAyahs = await _apiService.getSurahTajweed(chapterNumber);
    await _databaseService.saveAyahs(apiAyahs);
    return apiAyahs;
  }

  Future<List<Ayah>> getJuzTajweed(int juzNumber) async {
    try {
      // Always fetch complete Juz from API / SharedPreferences cache first
      final apiAyahs = await _apiService.getJuzTajweed(juzNumber);
      if (apiAyahs.isNotEmpty) {
        await _databaseService.saveAyahs(apiAyahs);
        return apiAyahs;
      }
    } catch (_) {}

    // Fallback to database
    final localAyahs = await _databaseService.getAyahsForJuz(juzNumber);
    if (localAyahs.isNotEmpty) return localAyahs;

    return [];
  }

  Future<List<Ayah>> getPageTajweed(int pageNumber) => 
      _apiService.getPageTajweed(pageNumber);

  Future<List<Ayah>> getPageQcfV2(int pageNumber) async {
    try {
      final localWords = await _databaseService.getQcfWordsForPage(pageNumber);
      if (localWords.isNotEmpty) {
        final Map<String, List<QuranWord>> verseMap = {};
        for (var word in localWords) {
          final vKey = word.verseKey ?? '';
          verseMap.putIfAbsent(vKey, () => []).add(word);
        }
        final List<Ayah> ayahs = [];
        verseMap.forEach((vKey, words) {
          final firstWord = words.first;
          ayahs.add(Ayah(
            number: firstWord.id ?? 0,
            text: words.map((w) => w.textUthmani ?? '').join(' '),
            numberInSurah: 0,
            juz: 1,
            manzil: 1,
            page: pageNumber,
            ruku: 1,
            hizbQuarter: 1,
            sajda: false,
            verseKey: vKey,
            words: words,
          ));
        });
        return ayahs;
      }
    } catch (_) {}

    final apiAyahs = await _apiService.getPageQcfV2(pageNumber);
    if (apiAyahs.isNotEmpty) {
      try {
        final List<QuranWord> allWords = [];
        for (var ayah in apiAyahs) {
          allWords.addAll(ayah.words);
        }
        if (allWords.isNotEmpty) {
          await _databaseService.saveQcfWords(allWords);
        }
      } catch (_) {}
    }
    return apiAyahs;
  }

  Future<List<Map<String, String>>> getSurahTranslation(int chapterNumber) => 
      _apiService.getSurahTranslation(chapterNumber);

  Future<void> saveResumePoint(ResumeData data) => _localStorageService.saveResumeData(data);

  ResumeData? getResumePoint() => _localStorageService.getResumeData();

  bool getPageReadStatus(int pageNumber) => _localStorageService.getPageReadStatus(pageNumber);

  Future<void> setPageReadStatus(int pageNumber, bool isRead) =>
      _localStorageService.setPageReadStatus(pageNumber, isRead);
}
