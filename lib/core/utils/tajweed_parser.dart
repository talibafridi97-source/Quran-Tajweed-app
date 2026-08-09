import 'package:flutter/material.dart';

class TajweedParser {
  static const Map<String, Color> _tajweedColors = {
    // Silent & Wasl
    'h': Color(0xFF9E9E9E), // Hamzatul Wasl
    's': Color(0xFF9E9E9E), // Silent letter
    'l': Color(0xFF9E9E9E), // Lam Shamsiyyah
    'r': Color(0xFF757575), // Idgham without Ghunnah

    // Ghunnah & Idgham
    'g': Color(0xFF169777), // Ghunnah
    'n': Color(0xFF169777), // Idgham with Ghunnah
    'u': Color(0xFF169777), // Idgham Shafawi
    'v': Color(0xFF00695C), // Iqlab
    'd': Color(0xFF00695C), // Iqlab

    // Ikhfa
    'i': Color(0xFF00838F), // Ikhfa
    'p': Color(0xFF0097A7), // Ikhfa Shafawi
    'c': Color(0xFF00838F), // Ikhfa
    'f': Color(0xFF0097A7), // Ikhfa Shafawi

    // Qalqalah
    'q': Color(0xFFD32F2F), // Qalqalah

    // Madds
    'o': Color(0xFFEF6C00), // Madd 4-5
    'm': Color(0xFFC62828), // Madd 6
    'w': Color(0xFFAD1457), // Madd 2
  };

  static List<InlineSpan> parse(
    String text, {
    double? fontSize,
    Color? defaultColor,
    String? fontFamily,
  }) {
    List<InlineSpan> spans = [];

    // Pre-cleaning HTML or residual tags if any
    String cleanText = text
        .replaceAll('/>', '')
        .replaceAll('tajweed>', '')
        .replaceAll('<tajweed>', '');

    // Pattern for bracketed Tajweed format: [rule:id]text OR [rule]text
    // e.g. [h:1]ٱ, [l]ل, [g]نّ, [q]ق
    final RegExp bracketRegex = RegExp(r'\[([a-z])(?::\d+)?\]([^\[]*)');

    int currentIndex = 0;
    final matches = bracketRegex.allMatches(cleanText);

    for (final match in matches) {
      // Add plain text before match
      if (match.start > currentIndex) {
        String plainText = cleanText.substring(currentIndex, match.start);
        if (plainText.isNotEmpty) {
          spans.add(TextSpan(
            text: plainText,
            style: TextStyle(
              color: defaultColor ?? Colors.black87,
              fontSize: fontSize,
              fontFamily: fontFamily,
              height: 1.8,
            ),
          ));
        }
      }

      String ruleCode = match.group(1) ?? '';
      String matchedText = match.group(2) ?? '';

      Color textColor = _tajweedColors[ruleCode] ?? (defaultColor ?? Colors.black87);

      spans.add(TextSpan(
        text: matchedText,
        style: TextStyle(
          color: textColor,
          fontSize: fontSize,
          fontFamily: fontFamily,
          fontWeight: FontWeight.bold,
          height: 1.8,
        ),
      ));

      currentIndex = match.end;
    }

    // Add remaining plain text
    if (currentIndex < cleanText.length) {
      String remainingText = cleanText.substring(currentIndex);
      if (remainingText.isNotEmpty) {
        spans.add(TextSpan(
          text: remainingText,
          style: TextStyle(
            color: defaultColor ?? Colors.black87,
            fontSize: fontSize,
            fontFamily: fontFamily,
            height: 1.8,
          ),
        ));
      }
    }

    return spans;
  }
}
