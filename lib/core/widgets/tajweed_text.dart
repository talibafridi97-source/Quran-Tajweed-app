import 'package:flutter/material.dart';
import '../constants/constants.dart';
import '../utils/tajweed_parser.dart';

import '../../models/ayah.dart';

class TajweedText extends StatelessWidget {
  final String? rawText;
  final List<Ayah>? ayahs;
  final double fontSize;
  final String? fontFamily;
  final TextAlign textAlign;
  final Color? defaultColor;
  final int? ayahNumber;
  final bool showTajweed;

  const TajweedText({
    super.key,
    this.rawText,
    this.ayahs,
    this.fontSize = 24,
    this.fontFamily,
    this.textAlign = TextAlign.justify,
    this.defaultColor,
    this.ayahNumber,
    this.showTajweed = true,
  });

  // Utility to convert digits to Arabic numerals: 1 -> ١
  String _toArabicDigits(int number) {
    const arabicDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    return number.toString().split('').map((digit) {
      final idx = int.tryParse(digit);
      return idx != null ? arabicDigits[idx] : digit;
    }).join();
  }

  @override
  Widget build(BuildContext context) {
    List<InlineSpan> spans = [];

    final activeFontFamily = (fontFamily != null && fontFamily!.isNotEmpty)
        ? fontFamily!
        : AppConstants.uthmaniFont;

    if (ayahs != null && ayahs!.isNotEmpty) {
      for (int i = 0; i < ayahs!.length; i++) {
        final ayah = ayahs![i];
        spans.addAll(TajweedParser.parse(
          ayah.text,
          fontSize: fontSize,
          fontFamily: activeFontFamily,
          defaultColor: defaultColor ?? Colors.black87,
          showTajweed: showTajweed,
        ));
        final arabicNum = _toArabicDigits(ayah.numberInSurah);
        spans.add(TextSpan(
          text: ' ﴿$arabicNum﴾ ',
          style: TextStyle(
            color: const Color(0xFFC9A227), // Gold for Ayah numbers
            fontSize: fontSize * 0.75,
            fontWeight: FontWeight.normal,
            fontFamily: activeFontFamily,
            height: 2.05,
          ),
        ));
      }
    } else if (rawText != null && rawText!.isNotEmpty) {
      spans.addAll(TajweedParser.parse(
        rawText!,
        fontSize: fontSize,
        fontFamily: activeFontFamily,
        defaultColor: defaultColor ?? Colors.black87,
        showTajweed: showTajweed,
      ));

      if (ayahNumber != null) {
        final arabicNum = _toArabicDigits(ayahNumber!);
        spans.add(TextSpan(
          text: ' ﴿$arabicNum﴾ ',
          style: TextStyle(
            color: const Color(0xFFC9A227),
            fontSize: fontSize * 0.75,
            fontWeight: FontWeight.normal,
            fontFamily: activeFontFamily,
            height: 2.05,
          ),
        ));
      }
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Text.rich(
        TextSpan(
          style: TextStyle(
            fontSize: fontSize,
            height: 2.05,
            letterSpacing: 0.0,
            fontFamily: activeFontFamily,
            color: defaultColor ?? Colors.black87,
            fontWeight: FontWeight.normal,
          ),
          children: spans,
        ),
        textAlign: textAlign,
        textDirection: TextDirection.rtl,
        softWrap: true,
        textHeightBehavior: const TextHeightBehavior(
          applyHeightToFirstAscent: true,
          applyHeightToLastDescent: true,
          leadingDistribution: TextLeadingDistribution.even,
        ),
      ),
    );
  }
}
