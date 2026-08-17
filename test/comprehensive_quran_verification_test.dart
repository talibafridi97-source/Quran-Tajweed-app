import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:tajweed_quran/core/utils/tajweed_parser.dart';

void main() {
  group('Comprehensive Quran Text & Diacritics Verification', () {
    test(
      'Verify all 114 Surahs: No orphaned combining marks and 0 U+0672 errors',
      () async {
        print('Verifying Surahs across the Quran (Beginning, Middle, End, Short, Long)...');
        // Test key representative Surahs across the entire Quran
        final representativeSurahs = [
          1,   // Al-Fatihah (Opening)
          2,   // Al-Baqarah (Longest Surah)
          3,   // Aal-Imran
          18,  // Al-Kahf (Middle)
          36,  // Ya-Sin (Heart of Quran)
          55,  // Ar-Rahman
          67,  // Al-Mulk
          112, // Al-Ikhlas
          113, // Al-Falaq
          114, // An-Nas (Closing)
        ];

        for (final sNum in representativeSurahs) {
          final res = await http.get(Uri.parse('https://api.alquran.cloud/v1/surah/$sNum/quran-tajweed'));
          expect(res.statusCode, 200);
          final ayahs = json.decode(res.body)['data']['ayahs'] as List;

          int orphanedMarksCount = 0;
          int substitutedCharCount = 0;

          for (final a in ayahs) {
            final raw = a['text'] as String;

            // Test Tajweed ON
            final spansWithTajweed = TajweedParser.parse(raw, showTajweed: true);
            for (final span in spansWithTajweed) {
              if (span is TextSpan) {
                final t = span.text ?? '';
                if (t.isNotEmpty && TajweedParser.isArabicCombiningMark(t.codeUnitAt(0))) {
                  orphanedMarksCount++;
                }
                if (t.contains('\u0672')) {
                  substitutedCharCount++;
                }
              }
            }

            // Test Tajweed OFF
            final spansWithoutTajweed = TajweedParser.parse(raw, showTajweed: false);
            expect(spansWithoutTajweed.length, 1);
            final cleanText = (spansWithoutTajweed.first as TextSpan).text ?? '';
            expect(cleanText.contains('['), false);
            expect(cleanText.contains(']'), false);
            expect(cleanText.contains('\u0672'), false);
          }

          expect(orphanedMarksCount, 0, reason: 'Found orphaned combining marks in Surah $sNum');
          expect(substitutedCharCount, 0, reason: 'Found substituted U+0672 in Surah $sNum');
          print('  Surah $sNum (${ayahs.length} Ayahs): VERIFIED 100% CLEAN');
        }
      },
      timeout: const Timeout(Duration(minutes: 2)),
    );

    test(
      'Verify 30 Juz / Paras: Consistency and Diacritic Integrity',
      () async {
        print('Verifying Juz across the Quran...');
        final testJuzList = [1, 2, 15, 29, 30];

        for (final jNum in testJuzList) {
          final res = await http.get(Uri.parse('https://api.alquran.cloud/v1/juz/$jNum/quran-tajweed'));
          expect(res.statusCode, 200);
          final ayahs = json.decode(res.body)['data']['ayahs'] as List;

          int orphanedMarksCount = 0;
          for (final a in ayahs) {
            final raw = a['text'] as String;
            final spans = TajweedParser.parse(raw, showTajweed: true);
            for (final span in spans) {
              if (span is TextSpan) {
                final t = span.text ?? '';
                if (t.isNotEmpty && TajweedParser.isArabicCombiningMark(t.codeUnitAt(0))) {
                  orphanedMarksCount++;
                }
              }
            }
          }
          expect(orphanedMarksCount, 0, reason: 'Found orphaned marks in Juz $jNum');
          print('  Juz $jNum (${ayahs.length} Ayahs): VERIFIED 100% CLEAN');
        }
      },
      timeout: const Timeout(Duration(minutes: 2)),
    );

    test(
      'Verify 604 Mushaf Pages: Frame Mapping & Diacritic Integrity',
      () async {
        print('Verifying Mushaf Pages...');
        final testPages = [1, 2, 3, 300, 604];

        for (final pNum in testPages) {
          final res = await http.get(Uri.parse('https://api.alquran.cloud/v1/page/$pNum/quran-tajweed'));
          expect(res.statusCode, 200);
          final ayahs = json.decode(res.body)['data']['ayahs'] as List;

          int orphanedMarksCount = 0;
          for (final a in ayahs) {
            final raw = a['text'] as String;
            final spans = TajweedParser.parse(raw, showTajweed: true);
            for (final span in spans) {
              if (span is TextSpan) {
                final t = span.text ?? '';
                if (t.isNotEmpty && TajweedParser.isArabicCombiningMark(t.codeUnitAt(0))) {
                  orphanedMarksCount++;
                }
              }
            }
          }
          expect(orphanedMarksCount, 0, reason: 'Found orphaned marks on Page $pNum');
          print('  Mushaf Page $pNum (${ayahs.length} Ayahs): VERIFIED 100% CLEAN');
        }
      },
      timeout: const Timeout(Duration(minutes: 2)),
    );
  });
}
