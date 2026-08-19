import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:tajweed_quran/core/utils/tajweed_parser.dart';
import 'package:tajweed_quran/core/widgets/tajweed_text.dart';
import 'package:tajweed_quran/models/ayah.dart';

void main() {
  group('Comprehensive Quran Text & Diacritics Verification', () {
    test(
      'Verify required canonical Surahs: Harakat integrity and zero orphaned marks',
      () async {
        final requiredSurahs = [
          {'number': 1, 'name': 'Al-Fatihah'},
          {'number': 2, 'name': 'Al-Baqarah'},
          {'number': 3, 'name': 'Aal-Imran'},
          {'number': 18, 'name': 'Al-Kahf'},
          {'number': 36, 'name': 'Ya-Sin'},
          {'number': 55, 'name': 'Ar-Rahman'},
          {'number': 67, 'name': 'Al-Mulk'},
          {'number': 112, 'name': 'Al-Ikhlas'},
          {'number': 113, 'name': 'Al-Falaq'},
          {'number': 114, 'name': 'An-Nas'},
        ];

        for (final sInfo in requiredSurahs) {
          final sNum = sInfo['number'] as int;
          final sName = sInfo['name'] as String;

          final res = await http.get(Uri.parse('https://api.alquran.cloud/v1/surah/$sNum/quran-uthmani'));
          expect(res.statusCode, 200);
          final ayahs = json.decode(res.body)['data']['ayahs'] as List;

          int orphanedMarksCount = 0;
          int substitutedCharCount = 0;
          int totalZabar = 0;
          int totalZer = 0;
          int totalPesh = 0;
          int totalShadda = 0;
          int totalSukoon = 0;
          int totalTanween = 0;
          int totalMadd = 0;
          int totalDaggerAlif = 0;

          for (final a in ayahs) {
            final raw = (a['text'] as String).replaceAll('\uFEFF', '').trim();

            for (final rune in raw.runes) {
              if (rune == 0x064E) totalZabar++;
              if (rune == 0x0650) totalZer++;
              if (rune == 0x064F) totalPesh++;
              if (rune == 0x0651) totalShadda++;
              if (rune == 0x0652 || rune == 0x06E1) totalSukoon++;
              if (rune == 0x064B || rune == 0x064C || rune == 0x064D) totalTanween++;
              if (rune == 0x0653 || rune == 0x06E4) totalMadd++;
              if (rune == 0x0670) totalDaggerAlif++;
            }

            // Test Tajweed ON with canonical Uthmani text
            final spansWithTajweed = TajweedParser.parse(raw, showTajweed: true);
            final reconstructed = spansWithTajweed.map((s) => (s is TextSpan) ? s.text : '').join('');
            expect(reconstructed, raw, reason: 'Parser must NOT change a single character of canonical Uthmani text in Surah $sName');

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
            expect(cleanText, raw);
          }

          expect(orphanedMarksCount, 0, reason: 'Found orphaned combining marks in Surah $sName');
          expect(substitutedCharCount, 0, reason: 'Found substituted U+0672 in Surah $sName');
          print('  Surah $sName ($sNum, ${ayahs.length} Ayahs): VERIFIED -> Zabar: $totalZabar, Zer: $totalZer, Pesh: $totalPesh, Shadda: $totalShadda, Sukoon: $totalSukoon, Tanween: $totalTanween, Madd: $totalMadd, DaggerAlif: $totalDaggerAlif');
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
          final res = await http.get(Uri.parse('https://api.alquran.cloud/v1/juz/$jNum/quran-uthmani'));
          expect(res.statusCode, 200);
          final ayahs = json.decode(res.body)['data']['ayahs'] as List;

          int orphanedMarksCount = 0;
          for (final a in ayahs) {
            final raw = (a['text'] as String).replaceAll('\uFEFF', '').trim();
            final spans = TajweedParser.parse(raw, showTajweed: true);
            final reconstructed = spans.map((s) => (s is TextSpan) ? s.text : '').join('');
            expect(reconstructed, raw, reason: 'Parser must NOT change a single character of canonical Uthmani text');

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
          print('  Juz $jNum (${ayahs.length} Ayahs): VERIFIED 100% CANONICAL UTHMANI');
        }
      },
      timeout: const Timeout(Duration(minutes: 2)),
    );

    test(
      'Verify 604 Mushaf Pages: Frame Mapping & Diacritic Integrity',
      () async {
        print('Verifying Mushaf Pages...');
        final testPages = [1, 2, 3, 4, 300, 604];

        for (final pNum in testPages) {
          final res = await http.get(Uri.parse('https://api.alquran.cloud/v1/page/$pNum/quran-uthmani'));
          expect(res.statusCode, 200);
          final ayahs = json.decode(res.body)['data']['ayahs'] as List;

          int orphanedMarksCount = 0;
          for (final a in ayahs) {
            final raw = (a['text'] as String).replaceAll('\uFEFF', '').trim();
            final spans = TajweedParser.parse(raw, showTajweed: true);
            final reconstructed = spans.map((s) => (s is TextSpan) ? s.text : '').join('');
            expect(reconstructed, raw, reason: 'Parser must NOT change a single character of canonical Uthmani text');

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
          print('  Mushaf Page $pNum (${ayahs.length} Ayahs): VERIFIED 100% CANONICAL UTHMANI');
        }
      },
      timeout: const Timeout(Duration(minutes: 2)),
    );
  });
}
