import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/surah.dart';
import '../models/ayah.dart';
import 'local_storage_service.dart';

class ApiService {
  final http.Client _client;
  final LocalStorageService _storageService;
  static const String _baseUrl = 'https://api.alquran.cloud/v1';

  ApiService({http.Client? client, required LocalStorageService storageService})
      : _client = client ?? http.Client(),
        _storageService = storageService;

  Future<List<Surah>> getAllSurahs() async {
    const cacheKey = 'surah_list_v3';
    final cached = _storageService.getCachedString(cacheKey);
    if (cached != null) {
      try {
        final data = json.decode(cached);
        return (data as List).map((s) => Surah.fromJson(s)).toList();
      } catch (_) {}
    }

    final response = await _client.get(Uri.parse('$_baseUrl/surah'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final list = data['data'] as List;
      await _storageService.cacheString(cacheKey, json.encode(list));
      return list.map((s) => Surah.fromJson(s)).toList();
    }
    throw Exception('Failed to load Surahs from Quran API. Please check your internet connection.');
  }

  Future<List<Ayah>> getSurahTajweed(int surahNumber) async {
    final cacheKey = 'surah_uthmani_v4_$surahNumber';
    final cached = _storageService.getCachedString(cacheKey);
    if (cached != null) {
      try {
        final data = json.decode(cached);
        return (data as List).map((a) => Ayah.fromJson(a)).toList();
      } catch (_) {}
    }

    final response = await _client.get(Uri.parse('$_baseUrl/surah/$surahNumber/quran-uthmani'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final ayahsList = data['data']['ayahs'] as List;
      await _storageService.cacheString(cacheKey, json.encode(ayahsList));
      return ayahsList.map((a) => Ayah.fromJson(a)).toList();
    }
    throw Exception('Unable to load Surah $surahNumber content. Please check internet connection.');
  }

  Future<List<Ayah>> getJuzTajweed(int juzNumber) async {
    final cacheKey = 'juz_uthmani_v4_$juzNumber';
    final cached = _storageService.getCachedString(cacheKey);
    if (cached != null) {
      try {
        final data = json.decode(cached);
        return (data as List).map((a) => Ayah.fromJson(a)).toList();
      } catch (_) {}
    }

    final response = await _client.get(Uri.parse('$_baseUrl/juz/$juzNumber/quran-uthmani'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final ayahsList = data['data']['ayahs'] as List;
      await _storageService.cacheString(cacheKey, json.encode(ayahsList));
      return ayahsList.map((a) => Ayah.fromJson(a)).toList();
    }
    throw Exception('Unable to load Para $juzNumber content. Please check internet connection.');
  }

  Future<List<Ayah>> getPageTajweed(int pageNumber) async {
    final cacheKey = 'page_uthmani_v4_$pageNumber';
    final cached = _storageService.getCachedString(cacheKey);
    if (cached != null) {
      try {
        final data = json.decode(cached);
        return (data as List).map((a) => Ayah.fromJson(a)).toList();
      } catch (_) {}
    }

    final response = await _client.get(Uri.parse('$_baseUrl/page/$pageNumber/quran-uthmani'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final ayahsList = data['data']['ayahs'] as List;
      await _storageService.cacheString(cacheKey, json.encode(ayahsList));
      return ayahsList.map((a) => Ayah.fromJson(a)).toList();
    }
    throw Exception('Unable to load Page $pageNumber content. Please check internet connection.');
  }

  Future<List<Map<String, String>>> getSurahTranslation(int surahNumber) async {
    final response = await _client.get(Uri.parse('$_baseUrl/surah/$surahNumber/ur.jalandhry'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['data']['ayahs'] as List).map<Map<String, String>>((a) => {
        'text': a['text'].toString(),
      }).toList();
    }
    throw Exception('Failed to load Translation');
  }
}
