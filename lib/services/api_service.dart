import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/surah.dart';
import '../models/ayah.dart';
import '../core/config/app_config.dart';
import 'local_storage_service.dart';

class ApiService {
  final http.Client _client;
  final LocalStorageService _storageService;
  static const String _baseUrl = 'https://api.alquran.cloud/v1';

  ApiService({http.Client? client, required LocalStorageService storageService})
      : _client = client ?? http.Client(),
        _storageService = storageService;

  Future<List<Surah>> getAllSurahs() async {
    const cacheKey = 'surah_list_v5';
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

  static List<Ayah> _parseAndSanitizeAyahs(List dynamicList) {
    return dynamicList.map((a) {
      final map = Map<String, dynamic>.from(a as Map);
      if (map['text'] is String) {
        // Strip BOM and clean edges without altering any Arabic/Quranic characters
        map['text'] = (map['text'] as String).replaceAll('\uFEFF', '').trim();
      }
      return Ayah.fromJson(map);
    }).toList();
  }

  Future<List<Ayah>> getSurahTajweed(int surahNumber) async {
    final cacheKey = 'surah_uthmani_v5_$surahNumber';
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
      final parsed = _parseAndSanitizeAyahs(ayahsList);
      await _storageService.cacheString(cacheKey, json.encode(parsed.map((a) => a.toJson()).toList()));
      return parsed;
    }
    throw Exception('Unable to load Surah $surahNumber content. Please check internet connection.');
  }

  Future<List<Ayah>> getJuzTajweed(int juzNumber) async {
    final cacheKey = 'juz_uthmani_v5_$juzNumber';
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
      final parsed = _parseAndSanitizeAyahs(ayahsList);
      await _storageService.cacheString(cacheKey, json.encode(parsed.map((a) => a.toJson()).toList()));
      return parsed;
    }
    throw Exception('Unable to load Para $juzNumber content. Please check internet connection.');
  }

  Future<List<Ayah>> getPageTajweed(int pageNumber) async {
    final cacheKey = 'page_uthmani_v5_$pageNumber';
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
      final parsed = _parseAndSanitizeAyahs(ayahsList);
      await _storageService.cacheString(cacheKey, json.encode(parsed.map((a) => a.toJson()).toList()));
      return parsed;
    }
    throw Exception('Unable to load Page $pageNumber content. Please check internet connection.');
  }

  Future<List<Ayah>> getPageQcfV2(int pageNumber) async {
    final cacheKey = 'page_qcf_v6_$pageNumber';
    final cached = _storageService.getCachedString(cacheKey);
    if (cached != null) {
      try {
        final data = json.decode(cached);
        return (data as List).map((a) => Ayah.fromJson(a as Map<String, dynamic>)).toList();
      } catch (_) {}
    }

    final url = 'https://api.quran.com/api/v4/verses/by_page/$pageNumber?mushaf=1&words=true&word_fields=code_v2,text_uthmani,line_number,page_number,v2_page,char_type_name';
    final response = await _client.get(
      Uri.parse(url),
      headers: AppConfig.apiHeaders,
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final versesList = data['verses'] as List? ?? [];
      final List<Ayah> ayahs = [];

      for (final v in versesList) {
        final vMap = Map<String, dynamic>.from(v as Map);
        final ayah = Ayah.fromJson(vMap);
        ayahs.add(ayah);
      }

      await _storageService.cacheString(
        cacheKey,
        json.encode(ayahs.map((a) => a.toJson()).toList()),
      );
      return ayahs;
    }
    throw Exception('Unable to load Page $pageNumber QCF data. Please check internet connection.');
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
