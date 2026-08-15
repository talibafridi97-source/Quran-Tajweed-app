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
      throw Exception('Book ${book.name} metadata is not available.');
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

    if (cachedAra != null) {
      try {
        araData = json.decode(cachedAra);
      } catch (_) {}
    }
    if (cachedUrd != null) {
      try {
        urdData = json.decode(cachedUrd);
      } catch (_) {}
    }

    if (araData == null) {
      // Official endpoint structure: /editions/{editionName}/sections/{sectionNo}.json
      Uri araUri = Uri.parse('$_baseUrl/editions/ara-${book.id}/sections/${chapter.id}.json');
      var resAra = await _client.get(araUri);
      
      if (resAra.statusCode != 200) {
        // Fallback endpoint structure: /editions/{editionName}/{sectionNo}.json
        araUri = Uri.parse('$_baseUrl/editions/ara-${book.id}/${chapter.id}.json');
        resAra = await _client.get(araUri);
      }

      if (resAra.statusCode == 200) {
        araData = json.decode(resAra.body);
        await _storageService.cacheString(cacheKeyAra, resAra.body);
      } else {
        throw Exception('This Hadith is currently unavailable. Please try again later.');
      }
    }

    if (urdData == null) {
      try {
        Uri urdUri = Uri.parse('$_baseUrl/editions/urd-${book.id}/sections/${chapter.id}.json');
        var resUrd = await _client.get(urdUri);
        if (resUrd.statusCode != 200) {
          urdUri = Uri.parse('$_baseUrl/editions/urd-${book.id}/${chapter.id}.json');
          resUrd = await _client.get(urdUri);
        }
        if (resUrd.statusCode == 200) {
          urdData = json.decode(resUrd.body);
          await _storageService.cacheString(cacheKeyUrd, resUrd.body);
        }
      } catch (_) {
        // Urdu edition fetch failure is handled gracefully below
      }
    }

    final araList = (araData != null && araData['hadiths'] is List) ? araData['hadiths'] as List : null;
    if (araList == null || araList.isEmpty) {
      throw Exception('This Hadith is currently unavailable. Please try again later.');
    }

    final urdList = (urdData != null && urdData['hadiths'] is List) ? urdData['hadiths'] as List : [];

    Map<int, Map<String, dynamic>> urdMap = {};
    for (var u in urdList) {
      if (u is Map<String, dynamic>) {
        int hNum = u['hadithnumber'] ?? 0;
        urdMap[hNum] = u;
      }
    }

    List<HadithItem> items = [];
    for (var a in araList) {
      if (a is Map<String, dynamic>) {
        int hNum = a['hadithnumber'] ?? 0;
        Map<String, dynamic> uJson = urdMap[hNum] ?? {'text': 'اردو ترجمہ اس باب کا جلد شامل کیا جائے گا'};

        items.add(HadithItem.fromJson(
          arabicJson: a,
          urduJson: uJson,
          bookName: book.name,
          chapterTitle: chapter.title,
        ));
      }
    }

    if (items.isEmpty) {
      throw Exception('This Hadith is currently unavailable. Please try again later.');
    }

    return items;
  }
}
