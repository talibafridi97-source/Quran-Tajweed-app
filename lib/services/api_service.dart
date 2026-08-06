import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/surah.dart';

class ApiService {
  final http.Client _client = http.Client();
  static const String _baseUrl = 'https://api.quran.com/api/v4';

  Future<List<Surah>> getAllSurahs() async {
    final response = await _client.get(Uri.parse('$_baseUrl/chapters'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['chapters'] as List).map((s) {
        return Surah(
          number: s['id'],
          name: s['name_arabic'],
          englishName: s['name_simple'],
          englishNameTranslation: s['translated_name']['name'],
          numberOfAyahs: s['verses_count'],
          revelationType: s['revelation_place'],
        );
      }).toList();
    } else {
      throw Exception('Failed to load Surahs');
    }
  }

  Future<List<Map<String, String>>> getSurahTajweed(int chapterNumber) async {
    final response = await _client.get(
      Uri.parse('$_baseUrl/quran/verses/uthmani_tajweed?chapter_number=$chapterNumber')
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['verses'] as List).map<Map<String, String>>((v) => {
        'verse_key': v['verse_key'].toString(),
        'text': v['text_uthmani_tajweed'].toString(),
      }).toList();
    }
    throw Exception('Failed to load Tajweed text');
  }

  Future<List<Map<String, String>>> getSurahTranslation(int chapterNumber, {int translationId = 97}) async {
    final response = await _client.get(
      Uri.parse('$_baseUrl/quran/translations/$translationId?chapter_number=$chapterNumber')
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['translations'] as List).map<Map<String, String>>((t) => {
        'text': t['text'].toString(),
      }).toList();
    }
    throw Exception('Failed to load Translation');
  }
}
