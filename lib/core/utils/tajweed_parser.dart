import 'package:flutter/material.dart';
import '../constants/constants.dart';

class TajweedParser {
  static const Map<String, Color> _tajweedColors = {
    // Silent & Wasl (Muted Gray)
    'h': Color(0xFF9E9E9E), // Hamzatul Wasl
    's': Color(0xFF9E9E9E), // Silent letter
    'l': Color(0xFF9E9E9E), // Lam Shamsiyyah
    'r': Color(0xFF757575), // Idgham without Ghunnah

    // Ghunnah & Idgham (Emerald Green)
    'g': Color(0xFF169777), // Ghunnah
    'n': Color(0xFF169777), // Idgham with Ghunnah
    'u': Color(0xFF169777), // Idgham Shafawi
    'a': Color(0xFF169777), // Idgham / Alif
    'v': Color(0xFF00695C), // Iqlab
    'd': Color(0xFF00695C), // Iqlab

    // Ikhfa (Sky Blue / Cyan)
    'i': Color(0xFF00838F), // Ikhfa
    'p': Color(0xFF0097A7), // Ikhfa Shafawi
    'c': Color(0xFF00838F), // Ikhfa
    'f': Color(0xFF0097A7), // Ikhfa Shafawi

    // Qalqalah (Crimson Red)
    'q': Color(0xFFD32F2F), // Qalqalah

    // Madds (Vibrant Orange / Deep Red / Magenta)
    'o': Color(0xFFEF6C00), // Madd 4-5 Harakat
    'm': Color(0xFFC62828), // Madd 6 Harakat
    'w': Color(0xFFAD1457), // Madd 2 Harakat
  };

  static List<InlineSpan> parse(
    String text, {
    double? fontSize,
    Color? defaultColor,
    String? fontFamily,
  }) {
    List<InlineSpan> spans = [];

    // Step 1: Pre-clean any HTML/XML artifacts if present
    String str = text
        .replaceAll('/>', '')
        .replaceAll('tajweed>', '')
        .replaceAll('<tajweed>', '');

    // Step 2: Pattern matching bracketed Tajweed tags:
    // Matches [rule:id[content] OR [rule:id]content OR [rule[content] OR [rule]content
    final RegExp tagRegex = RegExp(r'\[([a-zA-Z]+)(?::\d+)?(?:\]|\[)?([^\]\[]*)\]?');

    int index = 0;
    final matches = tagRegex.allMatches(str);

    final selectedFont = (fontFamily != null && fontFamily.isNotEmpty)
        ? fontFamily
        : AppConstants.uthmaniFont;

    TextStyle getStyle(Color col, {bool isBold = false}) {
      return TextStyle(
        color: col,
        fontSize: fontSize ?? 26,
        fontFamily: selectedFont,
        fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
        height: 2.0,
      );
    }

    for (final match in matches) {
      // Plain text before tag
      if (match.start > index) {
        String plain = str.substring(index, match.start);
        plain = _cleanRawMarkup(plain);
        if (plain.isNotEmpty) {
          spans.add(TextSpan(
            text: plain,
            style: getStyle(defaultColor ?? Colors.black87),
          ));
        }
      }

      String rule = match.group(1)?.toLowerCase() ?? '';
      String content = _cleanRawMarkup(match.group(2) ?? '');

      if (content.isNotEmpty) {
        Color color = _tajweedColors[rule] ?? (defaultColor ?? Colors.black87);
        spans.add(TextSpan(
          text: content,
          style: getStyle(color, isBold: true),
        ));
      }

      index = match.end;
    }

    // Remaining text after last match
    if (index < str.length) {
      String remaining = str.substring(index);
      remaining = _cleanRawMarkup(remaining);
      if (remaining.isNotEmpty) {
        spans.add(TextSpan(
          text: remaining,
          style: getStyle(defaultColor ?? Colors.black87),
        ));
      }
    }

    return spans;
  }

  // Helper method to strip out any raw bracket control tags or stray brackets
  static String _cleanRawMarkup(String s) {
    return s
        .replaceAll(RegExp(r'\[[a-zA-Z0-9:]+\]?'), '') // Strips any raw [h:1], [h:2], [n], etc.
        .replaceAll('[', '')
        .replaceAll(']', '');
  }
}
