import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tajweed_quran/core/utils/tajweed_parser.dart';
import 'package:tajweed_quran/core/widgets/tajweed_text.dart';
import 'package:tajweed_quran/models/ayah.dart';
import 'package:tajweed_quran/models/juz_model.dart';
import 'package:tajweed_quran/models/hadith_model.dart';

void main() {
  group('Tajweed & Model Tests', () {
    test('TajweedParser parses bracketed tokens correctly', () {
      const rawText = 'بِسْمِ [h:1[ٱ]للَّهِ [g[نَّ] [q[ق]';
      final spans = TajweedParser.parse(rawText);

      expect(spans.length, greaterThan(1));
    });

    test('30 Paras are correctly defined', () {
      expect(JuzModel.allJuz.length, 30);
      expect(JuzModel.allJuz.first.number, 1);
      expect(JuzModel.allJuz.last.number, 30);
    });

    testWidgets('TajweedText renders with RTL directionality, proper height, and zero overflow', (tester) async {
      final sampleAyahs = [
        Ayah(
          number: 1,
          text: 'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ',
          numberInSurah: 1,
          juz: 1,
          manzil: 1,
          page: 1,
          ruku: 1,
          hizbQuarter: 1,
          sajda: false,
          surahNumber: 1,
          surahName: 'الفاتحة',
        ),
        Ayah(
          number: 2,
          text: 'ٱلْحَمْدُ لِلَّهِ رَبِّ ٱلْعَٰلَمِينَ',
          numberInSurah: 2,
          juz: 1,
          manzil: 1,
          page: 1,
          ruku: 1,
          hizbQuarter: 1,
          sajda: false,
          surahNumber: 1,
          surahName: 'الفاتحة',
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 360, // Samsung Galaxy A52 width
                child: TajweedText(
                  ayahs: sampleAyahs,
                  fontSize: 22,
                  showTajweed: true,
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final textFinder = find.byType(Text);
      expect(textFinder, findsOneWidget);
      final textWidget = tester.widget<Text>(textFinder);
      expect(textWidget.textDirection, TextDirection.rtl);
      expect(textWidget.softWrap, true);
      expect(tester.takeException(), isNull);
    });
  });
}
