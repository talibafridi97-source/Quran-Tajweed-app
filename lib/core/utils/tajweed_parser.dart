import 'package:flutter/material.dart';
import '../constants/constants.dart';

class TajweedParser {
  static const Map<String, Color> _tajweedColors = {
    // Silent & Wasl (Muted Gray)
    'h': Color(0xFFAAAAAA), // Hamzatul Wasl
    's': Color(0xFFAAAAAA), // Silent letter
    'l': Color(0xFFAAAAAA), // Lam Shamsiyyah
    
    // Ghunnah (Orange)
    'n': Color(0xFFFF7E1E), // Ghunnah
    'g': Color(0xFFFF7E1E), // Ghunnah (alternate)

    // Idgham (Green)
    'm': Color(0xFF169777), // Idgham
    'u': Color(0xFF169777), // Idgham Shafawi
    'a': Color(0xFF169777), // Idgham / Alif
    'r': Color(0xFF169777), // Idgham without Ghunnah

    // Iqlab (Cyan)
    'b': Color(0xFF26BFFD), // Iqlab
    'd': Color(0xFF26BFFD), // Iqlab (alternate)
    'v': Color(0xFF26BFFD), // Iqlab (alternate)

    // Ikhfa (Purple)
    'i': Color(0xFF9400A8), // Ikhfa
    'p': Color(0xFF9400A8), // Ikhfa Shafawi
    'c': Color(0xFF9400A8), // Ikhfa (alternate)
    'f': Color(0xFF9400A8), // Ikhfa Shafawi (alternate)

    // Qalqalah (Red)
    'q': Color(0xFFDD0008), // Qalqalah

    // Madds (Blue Tones)
    'w': Color(0xFF000EBC), // Madd 6 Harakat (Dark Blue)
    'o': Color(0xFF4050FF), // Madd 4-5 Harakat (Blue)
    'j': Color(0xFF537FFF), // Madd 2 Harakat (Light Blue)
  };

  static List<InlineSpan> parse(
    String text, {
    double? fontSize,
    Color? defaultColor,
    String? fontFamily,
    bool showTajweed = true,
  }) {
    List<InlineSpan> spans = [];

    // Pre-clean: Remove any remaining XML tags if present, but keep the content
    String str = text.replaceAll(RegExp(r'<[^>]*>'), '');

    // Robust regex to capture Al-Quran Cloud Tajweed format: [rule:id[text]] OR [rule:id[text]
    // The format is typically [x:y[z]] where x is the rule, y is metadata, and z is the text.
    final RegExp tagRegex = RegExp(r'\[([a-zA-Z]+):?\d*\[([^\]]+)\]?\]?');

    int index = 0;
    final matches = tagRegex.allMatches(str);

    final selectedFont = (fontFamily != null && fontFamily.isNotEmpty)
        ? fontFamily
        : AppConstants.uthmaniFont;

    TextStyle getStyle(Color col) {
      return TextStyle(
        color: col,
        fontSize: fontSize ?? 26,
        fontFamily: selectedFont,
        fontWeight: FontWeight.normal,
        height: 1.95,
        letterSpacing: 0.0,
      );
    }

    for (final match in matches) {
      // Plain text before the tag
      if (match.start > index) {
        String plain = str.substring(index, match.start);
        if (plain.isNotEmpty) {
          spans.add(TextSpan(
            text: plain,
            style: getStyle(defaultColor ?? Colors.black87),
          ));
        }
      }

      String rule = match.group(1)?.toLowerCase() ?? '';
      String content = match.group(2) ?? '';

      if (content.isNotEmpty) {
        Color color = showTajweed
            ? (_tajweedColors[rule] ?? (defaultColor ?? Colors.black87))
            : (defaultColor ?? Colors.black87);
        spans.add(TextSpan(
          text: content,
          style: getStyle(color),
        ));
      }

      index = match.end;
    }

    // Remaining text after last match
    if (index < str.length) {
      String remaining = str.substring(index);
      if (remaining.isNotEmpty) {
        spans.add(TextSpan(
          text: remaining,
          style: getStyle(defaultColor ?? Colors.black87),
        ));
      }
    }

    return spans;
  }
}
