import 'package:flutter_test/flutter_test.dart';
import 'package:tajweed_quran/core/utils/tajweed_parser.dart';
import 'package:flutter/material.dart';

void main() {
  group('Tajweed Parser Verification', () {
    test('Surah Al-Fatihah Ayah 1 Tajweed parsing without raw tags', () {
      const rawText = 'بِسْمِ [h:1[ٱ]للَّهِ [h:2[ٱ][l[ل]رَّحْمَ[n[ـٰ]نِ [h:3[ٱ][l[ل]رَّح[p[ِي]مِ';
      final spans = TajweedParser.parse(rawText);

      // Verify no raw tags like [h:1], [h:2], etc. exist in span text
      for (final span in spans) {
        if (span is TextSpan) {
          final text = span.text ?? '';
          expect(text.contains('[h:'), false, reason: 'Found raw tag in: $text');
          expect(text.contains('[l['), false, reason: 'Found raw tag in: $text');
          expect(text.contains('[n['), false, reason: 'Found raw tag in: $text');
          expect(text.contains('[p['), false, reason: 'Found raw tag in: $text');
          expect(text.contains(']'), false, reason: 'Found trailing bracket in: $text');
        }
      }
    });

    test('Multiple complex Tajweed rules parsing', () {
      const rawText = 'وَ[h:9999[ٱ]لَّذِينَ يُؤْمِنُونَ بِم[o[َآ] أُ[f:17[نز]ِلَ إِلَيْكَ وَم[o[َآ] أُ[f:17[نز]ِلَ مِ[f:18[ن ق]َ[q:19[بْ]لِكَ';
      final spans = TajweedParser.parse(rawText);

      for (final span in spans) {
        if (span is TextSpan) {
          final text = span.text ?? '';
          expect(text.contains('['), false, reason: 'Found bracket in: $text');
          expect(text.contains(']'), false, reason: 'Found bracket in: $text');
        }
      }
    });
  });
}
