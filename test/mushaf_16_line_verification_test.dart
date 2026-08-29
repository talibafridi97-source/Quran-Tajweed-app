import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:tajweed_quran/models/ayah.dart';
import 'package:tajweed_quran/models/surah.dart';
import 'package:tajweed_quran/models/mushaf_16_line_model.dart';
import 'package:tajweed_quran/services/mushaf_16_line_layout_service.dart';
import 'package:tajweed_quran/core/widgets/mushaf_16_line_view.dart';
import 'package:tajweed_quran/core/utils/tajweed_parser.dart';

void main() {
  group('30-Para 16-Line Professional Mushaf Layout & Pagination Verification', () {
    late List<Surah> surahs;
    late List<Ayah> allAyahs;
    late List<Mushaf16LinePage> pages;

    setUpAll(() async {
      HttpOverrides.global = null;
      print('Fetching complete canonical Quran dataset for 30-Para 16-line verification...');
      final client = http.Client();

      final surahRes = await client.get(Uri.parse('https://api.alquran.cloud/v1/surah'));
      expect(surahRes.statusCode, 200);
      final surahData = json.decode(surahRes.body)['data'] as List;
      surahs = surahData.map((s) => Surah.fromJson(s as Map<String, dynamic>)).toList();
      expect(surahs.length, 114);

      // Fetch all Ayahs across 114 Surahs / 30 Juz
      allAyahs = [];
      for (int j = 1; j <= 30; j++) {
        final jRes = await client.get(Uri.parse('https://api.alquran.cloud/v1/juz/$j/quran-uthmani'));
        expect(jRes.statusCode, 200);
        final aList = json.decode(jRes.body)['data']['ayahs'] as List;
        for (final a in aList) {
          final map = Map<String, dynamic>.from(a as Map);
          map['text'] = (map['text'] as String).replaceAll('\uFEFF', '').trim();
          allAyahs.add(Ayah.fromJson(map));
        }
      }
      expect(allAyahs.length, 6236);

      print('Building 30-Para 16-line Mushaf pages from canonical dataset...');
      final layoutService = Mushaf16LineLayoutService.instance;
      layoutService.clearCache();
      pages = layoutService.buildAllPages(surahs: surahs, allAyahs: allAyahs);
    });

    test('1. Page 1 starts with Alhamdulillah and ends precisely at Waladwaleen (Surah 1:1-7)', () {
      final page1 = pages.first;
      expect(page1.pageNumber, 1);
      expect(page1.surahNumber, 1);
      expect(page1.lines.length, 16);

      // Verify Surah 1 header
      expect(page1.lines.first.isSurahHeader, isTrue);
      expect(page1.lines.first.surahNumber, 1);

      // Collect text segments from Page 1
      final page1Segments = page1.lines.expand((l) => l.segments).toList();
      final page1AyahNumbers = page1Segments.map((s) => s.ayahNumberInSurah).toSet().toList()..sort();
      expect(page1AyahNumbers, [1, 2, 3, 4, 5, 6, 7]);

      // Last Ayah end on Page 1 must be Ayah 7
      final lastAyahEnd = page1Segments.lastWhere((s) => s.isAyahEnd);
      expect(lastAyahEnd.ayahNumberInSurah, 7);
      expect(lastAyahEnd.surahNumber, 1);
    });

    test('2. Page 2 starts with Alif-Lam-Meem and ends precisely at Yooqinoon (Surah 2:1-4)', () {
      final page2 = pages[1];
      expect(page2.pageNumber, 2);
      expect(page2.surahNumber, 2);
      expect(page2.lines.length, 16);

      // Verify Surah 2 header & Bismillah
      expect(page2.lines[0].isSurahHeader, isTrue);
      expect(page2.lines[0].surahNumber, 2);
      expect(page2.lines[1].isBismillah, isTrue);

      // Collect text segments from Page 2
      final page2Segments = page2.lines.expand((l) => l.segments).toList();
      final page2AyahNumbers = page2Segments.map((s) => s.ayahNumberInSurah).toSet().toList()..sort();
      expect(page2AyahNumbers, [1, 2, 3, 4]);

      // First text segment on Page 2 must be Alif-Lam-Meem (Surah 2:1)
      final firstTextSegment = page2Segments.firstWhere((s) => !s.isAyahEnd);
      expect(firstTextSegment.ayahNumberInSurah, 1);
      expect(firstTextSegment.surahNumber, 2);

      // Last Ayah end on Page 2 must be Ayah 4 (ending on يُوقِنُونَ)
      final lastAyahEnd = page2Segments.lastWhere((s) => s.isAyahEnd);
      expect(lastAyahEnd.ayahNumberInSurah, 4);
      expect(lastAyahEnd.surahNumber, 2);
    });

    test('3. Page 3 starts precisely with Surah 2 Ayah 5 (Ulaika ala hudam mir rabbihim)', () {
      final page3 = pages[2];
      expect(page3.pageNumber, 3);
      expect(page3.surahNumber, 2);
      expect(page3.lines.length, 16);

      final page3Segments = page3.lines.expand((l) => l.segments).toList();
      final firstTextSegment = page3Segments.firstWhere((s) => !s.isAyahEnd);
      expect(firstTextSegment.ayahNumberInSurah, 5);
      expect(firstTextSegment.surahNumber, 2);
    });

    test('4. Every single page across all 30 Paras contains EXACTLY 16 line slots', () {
      expect(pages.isNotEmpty, isTrue);
      print('Total standardized 16-line pages generated: ${pages.length}');

      for (final page in pages) {
        expect(
          page.lines.length,
          16,
          reason: 'Page ${page.pageNumber} must have exactly 16 line slots, found ${page.lines.length}',
        );
      }
    });

    test('5. Total Ayah count is strictly 6,236 with ZERO missing and ZERO duplicates', () {
      final Set<String> seenAyahs = {};
      final List<String> duplicateAyahs = [];
      int totalAyahEndMarkers = 0;

      for (final page in pages) {
        for (final line in page.lines) {
          for (final seg in line.segments) {
            if (seg.isAyahEnd) {
              totalAyahEndMarkers++;
              final key = '${seg.surahNumber}:${seg.ayahNumberInSurah}';
              if (seenAyahs.contains(key)) {
                duplicateAyahs.add(key);
              } else {
                seenAyahs.add(key);
              }
            }
          }
        }
      }

      print('Unique Ayahs mapped: ${seenAyahs.length}');
      print('Total Ayah markers: $totalAyahEndMarkers');
      print('Duplicate Ayahs count: ${duplicateAyahs.length}');

      expect(seenAyahs.length, 6236, reason: 'Must contain all 6236 canonical Quran Ayahs');
      expect(totalAyahEndMarkers, 6236, reason: 'Must contain exactly 6236 Ayah end markers');
      expect(duplicateAyahs.isEmpty, isTrue, reason: 'Found duplicate Ayahs: $duplicateAyahs');
    });

    test('6. Surah and Ayah ordering is strictly sequential from 1:1 to 114:6', () {
      int expectedSurah = 1;
      int expectedAyah = 1;

      for (final page in pages) {
        for (final line in page.lines) {
          for (final seg in line.segments) {
            if (seg.isAyahEnd) {
              expect(seg.surahNumber, expectedSurah,
                  reason: 'Expected Surah $expectedSurah but found ${seg.surahNumber} on Page ${page.pageNumber}');
              expect(seg.ayahNumberInSurah, expectedAyah,
                  reason: 'Expected Ayah $expectedAyah in Surah $expectedSurah but found ${seg.ayahNumberInSurah} on Page ${page.pageNumber}');

              final totalInSurah = surahs[expectedSurah - 1].numberOfAyahs;
              if (expectedAyah < totalInSurah) {
                expectedAyah++;
              } else {
                expectedSurah++;
                expectedAyah = 1;
              }
            }
          }
        }
      }

      expect(expectedSurah, 115, reason: 'All 114 Surahs must be traversed completely');
    });

    test('7. Audio tagging (verseKey) is present on all text segments for live highlighting', () {
      for (final page in pages) {
        for (final line in page.lines) {
          if (line.isText) {
            for (final seg in line.segments) {
              expect(seg.verseKey.isNotEmpty, isTrue);
              expect(seg.verseKey.contains(':'), isTrue);
              expect(seg.surahNumber >= 1 && seg.surahNumber <= 114, isTrue);
              expect(seg.ayahNumberInSurah >= 1, isTrue);
            }
          }
        }
      }
    });

    test('8. TajweedParser executes with zero errors and zero orphaned marks across all lines', () {
      for (final page in pages) {
        for (final line in page.lines) {
          if (line.isText) {
            for (final seg in line.segments) {
              if (!seg.isAyahEnd) {
                final spans = TajweedParser.parse(seg.text, showTajweed: true);
                expect(spans.isNotEmpty, isTrue);
                final reconstructed = spans.map((s) => (s is TextSpan) ? (s.text ?? '') : '').join('');
                expect(reconstructed, seg.text, reason: 'TajweedParser must never mutate underlying word');
              }
            }
          }
        }
      }
    });

    testWidgets('9. Mushaf16LineView renders strictly 16 physical Expanded line slots with maxLines=1 and softWrap=false on Page 1, Page 2, middle page, and last page', (tester) async {
      final testPageIndices = [0, 1, pages.length ~/ 2, pages.length - 1];

      for (final pIdx in testPageIndices) {
        final p = pages[pIdx];

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                height: 600,
                width: 380,
                child: Mushaf16LineView(
                  page: p,
                  fontSize: 22.0,
                  fontFamily: 'NotoNaskhArabic',
                  showTajweed: true,
                ),
              ),
            ),
          ),
        );

        // Find the root Column of lines
        final columnFinder = find.byType(Column);
        expect(columnFinder, findsOneWidget);

        final Column col = tester.widget(columnFinder);
        expect(col.children.length, 16, reason: 'Page ${p.pageNumber} must contain exactly 16 Column children');

        // Verify all text widgets have maxLines: 1 and softWrap: false
        final richTextWidgets = tester.widgetList<RichText>(find.byType(RichText));
        for (final rt in richTextWidgets) {
          expect(rt.maxLines, 1, reason: 'Every line in Page ${p.pageNumber} must have maxLines: 1 to prevent multi-line wrapping');
          expect(rt.softWrap, false, reason: 'Every line in Page ${p.pageNumber} must have softWrap: false');
        }
      }
    });
  });
}
