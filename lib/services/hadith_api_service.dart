import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/hadith_model.dart';
import 'local_storage_service.dart';

class HadithApiService {
  final http.Client _client;
  final LocalStorageService _storageService;
  static const String _baseUrl = 'https://cdn.jsdelivr.net/gh/fawazahmed0/hadith-api@1';

  HadithApiService({http.Client? client, required LocalStorageService storageService})
      : _client = client ?? http.Client(),
        _storageService = storageService;

  Future<List<HadithChapter>> getChaptersForBook(HadithBook book) async {
    final cacheKey = 'hadith_chapters_${book.id}';
    final cached = _storageService.getCachedString(cacheKey);

    Map<String, dynamic>? infoData;
    if (cached != null) {
      try {
        infoData = json.decode(cached);
      } catch (_) {}
    }

    if (infoData == null) {
      final response = await _client.get(Uri.parse('$_baseUrl/info.json'));
      if (response.statusCode == 200) {
        infoData = json.decode(response.body);
        await _storageService.cacheString(cacheKey, response.body);
      } else {
        throw Exception('Failed to load Hadith metadata. Please check internet connection.');
      }
    }

    final bookData = infoData![book.id];
    if (bookData == null || bookData['metadata'] == null) {
      throw Exception('Book ${book.name} metadata not available.');
    }

    final sections = bookData['metadata']['sections'] as Map<String, dynamic>;
    final sectionDetails = bookData['metadata']['section_details'] as Map<String, dynamic>? ?? {};

    List<HadithChapter> chapters = [];
    sections.forEach((idStr, title) {
      if (idStr == '0' || title.toString().trim().isEmpty) return;

      int hFirst = 0;
      int hLast = 0;
      if (sectionDetails.containsKey(idStr)) {
        hFirst = sectionDetails[idStr]['hadithnumber_first'] ?? 0;
        hLast = sectionDetails[idStr]['hadithnumber_last'] ?? 0;
      }

      chapters.add(HadithChapter(
        id: idStr,
        title: title.toString(),
        bookId: book.id,
        hadithFirst: hFirst,
        hadithLast: hLast,
      ));
    });

    return chapters;
  }

  Future<List<HadithItem>> getHadithsForChapter({
    required HadithBook book,
    required HadithChapter chapter,
  }) async {
    final cacheKeyAra = 'hadith_ara_${book.id}_${chapter.id}';
    final cacheKeyUrd = 'hadith_urd_${book.id}_${chapter.id}';

    String? cachedAra = _storageService.getCachedString(cacheKeyAra);
    String? cachedUrd = _storageService.getCachedString(cacheKeyUrd);

    Map<String, dynamic>? araData;
    Map<String, dynamic>? urdData;

    if (cachedAra != null && cachedUrd != null) {
      try {
        araData = json.decode(cachedAra);
        urdData = json.decode(cachedUrd);
      } catch (_) {}
    }

    if (araData == null || urdData == null) {
      final araUri = Uri.parse('$_baseUrl/editions/ara-${book.id}/${chapter.id}.json');
      final urdUri = Uri.parse('$_baseUrl/editions/urd-${book.id}/${chapter.id}.json');

      final results = await Future.wait([
        _client.get(araUri),
        _client.get(urdUri),
      ]);

      if (results[0].statusCode == 200 && results[1].statusCode == 200) {
        araData = json.decode(results[0].body);
        urdData = json.decode(results[1].body);

        await _storageService.cacheString(cacheKeyAra, results[0].body);
        await _storageService.cacheString(cacheKeyUrd, results[1].body);
      } else {
        throw Exception('Failed to load Hadiths. Please check internet connection.');
      }
    }

    final araList = araData!['hadiths'] as List;
    final urdList = urdData!['hadiths'] as List;

    Map<int, Map<String, dynamic>> urdMap = {};
    for (var u in urdList) {
      int hNum = u['hadithnumber'] ?? 0;
      urdMap[hNum] = u as Map<String, dynamic>;
    }

    List<HadithItem> items = [];
    for (var a in araList) {
      int hNum = a['hadithnumber'] ?? 0;
      Map<String, dynamic> uJson = urdMap[hNum] ?? {'text': 'ترجمہ دستیاب نہیں ہے'};

      items.add(HadithItem.fromJson(
        arabicJson: a as Map<String, dynamic>,
        urduJson: uJson,
        bookName: book.name,
        chapterTitle: chapter.title,
      ));
    }

    return items;
  }
}
