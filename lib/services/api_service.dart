import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/surah.dart';

class ApiService {
  final http.Client _client = http.Client();
  static const String _baseUrl = 'https://api.alquran.cloud/v1';

  Future<List<Surah>> getAllSurahs() async {
    final response = await _client.get(Uri.parse('$_baseUrl/surah'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['data'] as List).map((s) => Surah.fromJson(s)).toList();
    }
    throw Exception('Failed to load Surahs');
  }

  Future<List<Map<String, String>>> getSurahTajweed(int surahNumber) async {
    final response = await _client.get(Uri.parse('$_baseUrl/surah/$surahNumber/quran-tajweed'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['data']['ayahs'] as List).map<Map<String, String>>((a) => {
        'text': a['text'].toString(),
        'verse_key': '$surahNumber:${a['numberInSurah']}',
      }).toList();
    }
    throw Exception('Failed to load Tajweed');
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

  Future<List<Map<String, String>>> getJuzTajweed(int juzNumber) async {
    final response = await _client.get(Uri.parse('$_baseUrl/juz/$juzNumber/quran-tajweed'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['data']['ayahs'] as List).map<Map<String, String>>((a) => {
        'text': a['text'].toString(),
        'verse_key': '${a['surah']['number']}:${a['numberInSurah']}',
      }).toList();
    }
    throw Exception('Failed to load Juz Tajweed');
  }

  Future<List<Map<String, String>>> getJuzTranslation(int juzNumber) async {
    final response = await _client.get(Uri.parse('$_baseUrl/juz/$juzNumber/ur.jalandhry'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['data']['ayahs'] as List).map<Map<String, String>>((a) => {
        'text': a['text'].toString(),
      }).toList();
    }
    throw Exception('Failed to load Juz Translation');
  }
}
