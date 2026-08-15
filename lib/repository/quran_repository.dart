import '../models/surah.dart';
import '../models/ayah.dart';
import '../services/api_service.dart';
import '../services/local_storage_service.dart';
import '../services/database_service.dart';
import '../models/resume_data.dart';

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

  Future<List<Map<String, String>>> getSurahTranslation(int chapterNumber) => 
      _apiService.getSurahTranslation(chapterNumber);

  Future<void> saveResumePoint(ResumeData data) => _localStorageService.saveResumeData(data);

  ResumeData? getResumePoint() => _localStorageService.getResumeData();

  bool getPageReadStatus(int pageNumber) => _localStorageService.getPageReadStatus(pageNumber);

  Future<void> setPageReadStatus(int pageNumber, bool isRead) =>
      _localStorageService.setPageReadStatus(pageNumber, isRead);
}
