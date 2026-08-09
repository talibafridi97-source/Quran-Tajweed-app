import 'package:flutter_test/flutter_test.dart';
import 'package:tajweed_quran/core/utils/tajweed_parser.dart';
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

    test('Authentic Hadith Books are available', () {
      final books = HadithBook.availableBooks;
      expect(books.length, greaterThanOrEqualTo(6));
      expect(books.any((b) => b.id == 'bukhari'), true);
      expect(books.any((b) => b.id == 'muslim'), true);
    });
  });
}
