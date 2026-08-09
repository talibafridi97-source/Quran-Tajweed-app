import 'package:flutter/material.dart';
import '../utils/tajweed_parser.dart';

class TajweedText extends StatelessWidget {
  final String rawText;
  final double fontSize;
  final String? fontFamily;
  final TextAlign textAlign;
  final Color? defaultColor;
  final int? ayahNumber;

  const TajweedText({
    super.key,
    required this.rawText,
    this.fontSize = 24,
    this.fontFamily,
    this.textAlign = TextAlign.right,
    this.defaultColor,
    this.ayahNumber,
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

    // Parse Tajweed text using the enhanced parser
    spans.addAll(TajweedParser.parse(
      rawText,
      fontSize: fontSize,
      fontFamily: fontFamily,
      defaultColor: defaultColor ?? Colors.black87,
    ));

    // Add Ayah Number badge at the end of text
    if (ayahNumber != null) {
      final arabicNum = _toArabicDigits(ayahNumber!);
      spans.add(TextSpan(
        text: ' ﴿$arabicNum﴾ ',
        style: TextStyle(
          color: const Color(0xFFD4AF37), // Gold for Ayah numbers
          fontSize: fontSize * 0.75,
          fontWeight: FontWeight.bold,
          fontFamily: fontFamily,
        ),
      ));
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: RichText(
        textAlign: textAlign,
        textDirection: TextDirection.rtl,
        text: TextSpan(children: spans),
      ),
    );
  }
}
