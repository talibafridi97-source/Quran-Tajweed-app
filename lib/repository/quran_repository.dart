import '../models/surah.dart';
import '../models/ayah.dart';
import '../services/api_service.dart';
import '../services/local_storage_service.dart';
import '../services/database_service.dart';
import '../models/resume_data.dart';
import '../models/quran_word.dart';

import '../models/translation_model.dart';
import '../models/tafsir_model.dart';

class QuranRepository {
  final ApiService _apiService;
  final LocalStorageService _localStorageService;
  final DatabaseService _databaseService;

  QuranRepository(this._apiService, this._localStorageService, this._databaseService);

  DatabaseService get databaseService => _databaseService;

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
      final apiAyahs = await _apiService.getJuzTajweed(juzNumber);
      if (apiAyahs.isNotEmpty) {
        await _databaseService.saveAyahs(apiAyahs);
        return apiAyahs;
      }
    } catch (_) {}

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

  // --- Multi-Translation with SQLite Offline Caching ---
  Future<List<AyahTranslation>> getSurahTranslations({
    required int surahNumber,
    required String editionId,
  }) async {
    // 1. Try local SQLite cache
    final local = await _databaseService.getTranslationsForSurah(surahNumber, editionId);
    if (local.isNotEmpty) return local;

    // 2. Fetch from API & cache
    try {
      final rawList = await _apiService.getSurahTranslationByEdition(surahNumber, editionId);
      final List<AyahTranslation> list = [];
      for (int i = 0; i < rawList.length; i++) {
        final item = rawList[i];
        final aNum = int.tryParse(item['numberInSurah'] ?? '') ?? (i + 1);
        list.add(AyahTranslation(
          surahNumber: surahNumber,
          ayahNumber: aNum,
          editionId: editionId,
          text: item['text'] ?? '',
        ));
      }
      if (list.isNotEmpty) {
        await _databaseService.saveTranslations(list);
      }
      return list;
    } catch (_) {
      return [];
    }
  }

  // --- Ayah Tafsir with SQLite Offline Caching ---
  Future<AyahTafsir?> getAyahTafsir({
    required int surahNumber,
    required int ayahNumber,
    required String tafsirId,
  }) async {
    // 1. Try local cache
    final local = await _databaseService.getTafsir(surahNumber, ayahNumber, tafsirId);
    if (local != null) return local;

    // 2. Fetch from API & cache
    try {
      final text = await _apiService.getAyahTafsir(surahNumber, ayahNumber, tafsirId);
      final edition = TafsirEdition.findById(tafsirId);
      final tafsir = AyahTafsir(
        surahNumber: surahNumber,
        ayahNumber: ayahNumber,
        tafsirId: tafsirId,
        authorName: edition.author,
        text: text,
        language: edition.language,
        updatedAt: DateTime.now(),
      );
      await _databaseService.saveTafsir(tafsir);
      return tafsir;
    } catch (e) {
      return null;
    }
  }

  // --- Universal Search ---
  Future<List<Map<String, dynamic>>> searchQuran(String query, {int limit = 60}) =>
      _databaseService.searchQuran(query, limit: limit);

  Future<List<Map<String, String>>> getSurahTranslation(int chapterNumber) => 
      _apiService.getSurahTranslation(chapterNumber);

  Future<void> saveResumePoint(ResumeData data) => _localStorageService.saveResumeData(data);

  ResumeData? getResumePoint() => _localStorageService.getResumeData();

  bool getPageReadStatus(int pageNumber) => _localStorageService.getPageReadStatus(pageNumber);

  Future<void> setPageReadStatus(int pageNumber, bool isRead) =>
      _localStorageService.setPageReadStatus(pageNumber, isRead);
}
