import '../models/surah.dart';
import '../models/ayah.dart';
import '../services/api_service.dart';
import '../services/local_storage_service.dart';
import '../models/resume_data.dart';

class QuranRepository {
  final ApiService _apiService;
  final LocalStorageService _localStorageService;

  QuranRepository(this._apiService, this._localStorageService);

  Future<List<Surah>> getAllSurahs() => _apiService.getAllSurahs();

  Future<List<Ayah>> getSurahTajweed(int chapterNumber) => 
      _apiService.getSurahTajweed(chapterNumber);

  Future<List<Ayah>> getJuzTajweed(int juzNumber) => 
      _apiService.getJuzTajweed(juzNumber);

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
