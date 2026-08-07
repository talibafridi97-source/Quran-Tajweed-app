import '../models/surah.dart';
import '../services/api_service.dart';
import '../services/local_storage_service.dart';
import '../models/resume_data.dart';

class QuranRepository {
  final ApiService _apiService;
  final LocalStorageService _localStorageService;

  QuranRepository(this._apiService, this._localStorageService);

  Future<List<Surah>> getAllSurahs() => _apiService.getAllSurahs();

  Future<List<Map<String, String>>> getSurahTajweed(int chapterNumber) => 
      _apiService.getSurahTajweed(chapterNumber);

  Future<List<Map<String, String>>> getSurahTranslation(int chapterNumber) => 
      _apiService.getSurahTranslation(chapterNumber);

  Future<List<Map<String, String>>> getJuzTajweed(int juzNumber) => 
      _apiService.getJuzTajweed(juzNumber);

  Future<List<Map<String, String>>> getJuzTranslation(int juzNumber) => 
      _apiService.getJuzTranslation(juzNumber);

  Future<void> saveResumePoint(ResumeData data) => _localStorageService.saveResumeData(data);

  ResumeData? getResumePoint() => _localStorageService.getResumeData();
}
