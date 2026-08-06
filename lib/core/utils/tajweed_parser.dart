import 'package:flutter/material.dart';

class TajweedParser {
  // Quran.com Tajweed Colors (Standardized)
  static const Map<String, Color> _tajweedColors = {
    'h': Color(0xFFAAAAAA), // Hamzatul Wasl - Grey
    's': Color(0xFFAAAAAA), // Silent - Grey
    'i': Color(0xFF33ABFF), // Ikhfa - Blue
    'p': Color(0xFF33ABFF), // Ikhfa Shafawi - Blue
    'g': Color(0xFF169777), // Ghunnah - Green
    'n': Color(0xFF169777), // Idgham with Ghunnah - Green
    'r': Color(0xFFAAAAAA), // Idgham without Ghunnah - Grey
    'q': Color(0xFFFF5252), // Qalqalah - Red/Orange
    'm': Color(0xFFFF291C), // Mad 6 harakat - Dark Red
    'o': Color(0xFFFF7E1C), // Mad 4-5 harakat - Orange
    'w': Color(0xFFFB92E0), // Mad 2 harakat - Pink
    'v': Color(0xFF169777), // Iqlab - Green
  };

  static List<InlineSpan> parse(String text, {double? fontSize, Color? defaultColor, String? fontFamily}) {
    List<InlineSpan> spans = [];
    
    // Regex to match [tag] followed by text until next [ or end
    final RegExp tagRegex = RegExp(r'\[([a-z])\]([^\[]*)');
    
    int lastMatchEnd = 0;

    // Check if text starts with a tag. If not, add initial plain text.
    if (!text.startsWith('[')) {
      int firstTag = text.indexOf('[');
      String initialText = firstTag == -1 ? text : text.substring(0, firstTag);
      spans.add(TextSpan(
        text: initialText,
        style: TextStyle(
          color: defaultColor ?? Colors.black,
          fontSize: fontSize,
          fontFamily: fontFamily,
        ),
      ));
      lastMatchEnd = initialText.length;
    }

    final matches = tagRegex.allMatches(text);

    for (final match in matches) {
      String tag = match.group(1) ?? '';
      String segmentText = match.group(2) ?? '';
      
      Color tagColor = _tajweedColors[tag] ?? (defaultColor ?? Colors.black);

      spans.add(TextSpan(
        text: segmentText,
        style: TextStyle(
          color: tagColor,
          fontSize: fontSize,
          fontFamily: fontFamily,
        ),
      ));
      
      lastMatchEnd = match.end;
    }

    // Add any trailing text
    if (lastMatchEnd < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastMatchEnd),
        style: TextStyle(
          color: defaultColor ?? Colors.black,
          fontSize: fontSize,
          fontFamily: fontFamily,
        ),
      ));
    }

    return spans;
  }
}
