import 'package:flutter/material.dart';

class TajweedParser {
  static const Map<String, Color> _tajweedColors = {
    'h': Color(0xFFAAAAAA), // Hamzatul Wasl
    's': Color(0xFFAAAAAA), // Silent
    'i': Color(0xFF33ABFF), // Ikhfa
    'p': Color(0xFF33ABFF), // Ikhfa Shafawi
    'g': Color(0xFF169777), // Ghunnah
    'n': Color(0xFF169777), // Idgham with Ghunnah
    'r': Color(0xFFAAAAAA), // Idgham without Ghunnah
    'q': Color(0xFFFF5252), // Qalqalah
    'm': Color(0xFFFF291C), // Mad 6
    'o': Color(0xFFFF7E1C), // Mad 4-5
    'w': Color(0xFFFB92E0), // Mad 2
    'v': Color(0xFF169777), // Iqlab
  };

  static List<InlineSpan> parse(String text, {double? fontSize, Color? defaultColor, String? fontFamily}) {
    List<InlineSpan> spans = [];
    
    // Regex for [g]text format
    final RegExp tagRegex = RegExp(r'\[([a-z])\]([^\[]*)');
    
    int lastMatchEnd = 0;

    if (!text.startsWith('[')) {
      int firstTag = text.indexOf('[');
      String initialText = firstTag == -1 ? text : text.substring(0, firstTag);
      spans.add(TextSpan(
        text: initialText,
        style: TextStyle(color: defaultColor ?? Colors.black, fontSize: fontSize, fontFamily: fontFamily),
      ));
      lastMatchEnd = initialText.length;
    }

    final matches = tagRegex.allMatches(text);

    for (final match in matches) {
      String tag = match.group(1) ?? '';
      String content = match.group(2) ?? '';
      
      Color tagColor = _tajweedColors[tag] ?? (defaultColor ?? Colors.black);

      spans.add(TextSpan(
        text: content,
        style: TextStyle(color: tagColor, fontSize: fontSize, fontFamily: fontFamily, fontWeight: FontWeight.bold),
      ));
      
      lastMatchEnd = match.end;
    }

    if (lastMatchEnd < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastMatchEnd),
        style: TextStyle(color: defaultColor ?? Colors.black, fontSize: fontSize, fontFamily: fontFamily),
      ));
    }

    return spans;
  }
}
