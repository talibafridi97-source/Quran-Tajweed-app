import 'dart:io';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../core/config/app_config.dart';

class QcfFontManager {
  static final Set<int> _loadedFonts = {};
  static final Map<int, Future<void>> _inFlightLoads = {};

  static String getFontFamily(int pageNumber) => 'QCF2_P$pageNumber';

  static bool isFontLoaded(int pageNumber) => _loadedFonts.contains(pageNumber);

  static Future<void> loadPageFont(int pageNumber) async {
    if (pageNumber < 1 || pageNumber > 604) return;
    if (_loadedFonts.contains(pageNumber)) return;

    if (_inFlightLoads.containsKey(pageNumber)) {
      await _inFlightLoads[pageNumber];
      return;
    }

    final future = _loadFontInternal(pageNumber);
    _inFlightLoads[pageNumber] = future;

    try {
      await future;
    } finally {
      _inFlightLoads.remove(pageNumber);
    }
  }

  static Future<void> _loadFontInternal(int pageNumber) async {
    final fontName = getFontFamily(pageNumber);
    Uint8List? fontBytes;

    try {
      final docDir = await getApplicationDocumentsDirectory();
      final fontDir = Directory('${docDir.path}/qcf_v2');
      if (!await fontDir.exists()) {
        await fontDir.create(recursive: true);
      }

      final fontFile = File('${fontDir.path}/p$pageNumber.ttf');

      if (await fontFile.exists() && await fontFile.length() > 1000) {
        fontBytes = await fontFile.readAsBytes();
      } else {
        fontBytes = await _downloadFontBytes(pageNumber);
        if (fontBytes != null && fontBytes.isNotEmpty) {
          await fontFile.writeAsBytes(fontBytes, flush: true);
        }
      }

      if (fontBytes != null && fontBytes.isNotEmpty) {
        final fontLoader = FontLoader(fontName);
        fontLoader.addFont(Future.value(ByteData.view(fontBytes.buffer)));
        await fontLoader.load();
        _loadedFonts.add(pageNumber);
      }
    } catch (e) {
      // Gracefully handle font loading errors
    }
  }

  static Future<Uint8List?> _downloadFontBytes(int pageNumber) async {
    final urls = [
      'https://verses.quran.com/fonts/quran/hafs/v2/ttf/p$pageNumber.ttf',
      'https://raw.githubusercontent.com/quran/quran.com-frontend-next/master/public/fonts/quran/hafs/v2/ttf/p$pageNumber.ttf'
    ];

    for (final url in urls) {
      try {
        final response = await http.get(
          Uri.parse(url),
          headers: AppConfig.apiHeaders,
        ).timeout(const Duration(seconds: 15));

        if (response.statusCode == 200 && response.bodyBytes.isNotEmpty) {
          return response.bodyBytes;
        }
      } catch (_) {
        // Try fallback mirror URL
      }
    }
    return null;
  }

  static void prefetchAdjacentFonts(int currentPage) {
    if (currentPage > 1) {
      loadPageFont(currentPage - 1);
    }
    if (currentPage < 604) {
      loadPageFont(currentPage + 1);
    }
  }
}

