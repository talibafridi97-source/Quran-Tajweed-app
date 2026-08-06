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
    List<InlineSpan> spans = [];

    // Add Ayah Number at the beginning if provided
    if (ayahNumber != null) {
      spans.add(TextSpan(
        text: '($ayahNumber) ',
        style: TextStyle(
          color: Theme.of(context).primaryColor,
          fontSize: fontSize * 0.7,
          fontWeight: FontWeight.bold,
          fontFamily: fontFamily,
        ),
      ));
    }

    // Parse Tajweed text
    spans.addAll(TajweedParser.parse(
      rawText,
      fontSize: fontSize,
      fontFamily: fontFamily,
      defaultColor: defaultColor ?? Theme.of(context).textTheme.bodyLarge?.color,
    ));

    return RichText(
      textAlign: textAlign,
      textDirection: TextDirection.rtl,
      text: TextSpan(children: spans),
    );
  }
}
