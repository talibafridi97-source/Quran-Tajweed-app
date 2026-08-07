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

  @override
  Widget build(BuildContext context) {
    // PRE-CLEANING: Remove some weird broken prefixes often seen in some APIs
    String cleanRawText = rawText.replaceAll('/>', '').replaceAll('tajweed>', '');

    List<InlineSpan> spans = [];

    // Add Ayah Number at the beginning if provided
    if (ayahNumber != null) {
      spans.add(TextSpan(
        text: ' ($ayahNumber) ',
        style: TextStyle(
          color: const Color(0xFF8B4513), // Brownish for Ayah numbers
          fontSize: fontSize * 0.8,
          fontWeight: FontWeight.bold,
          fontFamily: fontFamily,
        ),
      ));
    }

    // Parse Tajweed text using the updated XML/HTML parser
    spans.addAll(TajweedParser.parse(
      cleanRawText,
      fontSize: fontSize,
      fontFamily: fontFamily,
      defaultColor: defaultColor ?? Colors.black87,
    ));

    return RichText(
      textAlign: textAlign,
      textDirection: TextDirection.rtl,
      text: TextSpan(children: spans),
    );
  }
}
