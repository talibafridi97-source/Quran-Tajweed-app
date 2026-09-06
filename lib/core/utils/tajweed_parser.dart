import 'package:flutter/material.dart';
import '../constants/constants.dart';

class _SpanToken {
  String text;
  Color? color;
  _SpanToken(this.text, this.color);
}

class TajweedParser {
  // Calibrated colors to match high-quality Indo-Pak colored Mushaf screenshots
  static const Map<String, Color> _tajweedColors = {
    // Silent & Wasl (Muted Gray)
    'h': Color(0xFF9E9E9E), // Hamzatul Wasl
    's': Color(0xFF9E9E9E), // Silent letter
    'l': Color(0xFF9E9E9E), // Lam Shamsiyyah
    
    // Ghunnah (Authentic Orange/Amber)
    'n': Color(0xFFFF6D00), // Ghunnah
    'g': Color(0xFFFF6D00), // Alternate

    // Idgham (Vibrant Emerald Green)
    'm': Color(0xFF2E7D32), // Idgham
    'u': Color(0xFF2E7D32), 
    'a': Color(0xFF2E7D32), 
    'r': Color(0xFF2E7D32), 

    // Iqlab (Sky Blue)
    'b': Color(0xFF03A9F4), 
    'd': Color(0xFF03A9F4), 

    // Ikhfa (Royal Pink/Magenta - very common in Pakistani Mushafs)
    'i': Color(0xFFD81B60), 
    'p': Color(0xFFD81B60), 
    'c': Color(0xFFD81B60), 

    // Qalqalah (Blue)
    'q': Color(0xFF1976D2), 

    // Madds (Deep Red/Crimson)
    'w': Color(0xFFB71C1C), // Madd 6
    'o': Color(0xFFE91E63), // Madd 4-5
    'j': Color(0xFFFF4081), // Madd 2
  };

  static bool isArabicCombiningMark(int cu) {
    return (cu >= 0x0610 && cu <= 0x061A) ||
        (cu >= 0x064B && cu <= 0x065F) ||
        cu == 0x0670 ||
        (cu >= 0x06D6 && cu <= 0x06DC) ||
        (cu >= 0x06DF && cu <= 0x06E4) ||
        (cu >= 0x06E7 && cu <= 0x06E8) ||
        (cu >= 0x06EA && cu <= 0x06ED) ||
        (cu >= 0x08D4 && cu <= 0x08E1) ||
        (cu >= 0x08E3 && cu <= 0x08FF);
  }

  static List<String> toGraphemeClusters(String text) {
    List<String> clusters = [];
    StringBuffer current = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      int cu = text.codeUnitAt(i);
      if (isArabicCombiningMark(cu)) {
        current.writeCharCode(cu);
      } else {
        if (current.isNotEmpty) clusters.add(current.toString());
        current.clear();
        current.writeCharCode(cu);
      }
    }
    if (current.isNotEmpty) clusters.add(current.toString());
    return clusters;
  }

  static List<InlineSpan> _parseCanonicalUthmani(String text, TextStyle style, Color resolvedColor, bool showTajweed) {
    if (!showTajweed) return [TextSpan(text: text, style: style)];
    final clusters = toGraphemeClusters(text);
    final List<Color> colors = List.filled(clusters.length, resolvedColor);

    const qalqalahLetters = {'ق', 'ط', 'ب', 'ج', 'د'};
    const ikhfaLetters = {'ت', 'ث', 'ج', 'د', 'ذ', 'ز', 'س', 'ش', 'ص', 'ض', 'ط', 'ظ', 'ف', 'ق', 'ك'};
    const idghamLetters = {'ي', 'ر', 'م', 'ل', 'و', 'ن'};

    bool isTanween(String cl) => cl.contains('\u064B') || cl.contains('\u064C') || cl.contains('\u064D');
    bool isPlainNoonSakinah(String cl) => cl.startsWith('ن') && !cl.contains('\u064E') && !cl.contains('\u0650') && !cl.contains('\u064F') && !cl.contains('\u0651') && !cl.contains('\u0652');

    for (int i = 0; i < clusters.length; i++) {
      final cluster = clusters[i];
      if (cluster.isEmpty) continue;
      final base = cluster[0];
      if (base == '\u0671') colors[i] = _tajweedColors['h']!;
      else if (cluster.contains('\u06DF') || cluster.contains('\u06E0')) colors[i] = _tajweedColors['s']!;
      else if ((base == 'ن' || base == 'م') && cluster.contains('\u0651')) colors[i] = _tajweedColors['n']!;
      else if (cluster.contains('\u0653') || cluster.contains('\u06E4')) colors[i] = _tajweedColors['o']!;
      else if (cluster.contains('\u06E2') || cluster.contains('\u06ED')) colors[i] = _tajweedColors['b']!;
      else if (qalqalahLetters.contains(base) && (cluster.contains('\u0652') || cluster.contains('\u06E1'))) colors[i] = _tajweedColors['q']!;
      else if (isPlainNoonSakinah(cluster) || isTanween(cluster)) {
        int nextIdx = i + 1;
        while (nextIdx < clusters.length && clusters[nextIdx].trim().isEmpty) nextIdx++;
        if (nextIdx < clusters.length) {
          final nextBase = clusters[nextIdx].isNotEmpty ? clusters[nextIdx][0] : '';
          if (ikhfaLetters.contains(nextBase)) colors[i] = _tajweedColors['i']!;
          else if (idghamLetters.contains(nextBase)) colors[i] = _tajweedColors['m']!;
        }
      }
    }

    final List<InlineSpan> spans = [];
    StringBuffer buffer = StringBuffer();
    Color currentColor = colors.isNotEmpty ? colors[0] : resolvedColor;
    for (int i = 0; i < clusters.length; i++) {
      if (colors[i] == currentColor) buffer.write(clusters[i]);
      else {
        if (buffer.isNotEmpty) spans.add(TextSpan(text: buffer.toString(), style: style.copyWith(color: currentColor)));
        buffer.clear(); currentColor = colors[i]; buffer.write(clusters[i]);
      }
    }
    if (buffer.isNotEmpty) spans.add(TextSpan(text: buffer.toString(), style: style.copyWith(color: currentColor)));
    return spans;
  }

  static List<InlineSpan> parse(String text, {double? fontSize, Color? defaultColor, String? fontFamily, bool showTajweed = true}) {
    final selectedFont = (fontFamily != null && fontFamily.isNotEmpty) ? fontFamily : AppConstants.uthmaniFont;
    final resolvedColor = defaultColor ?? Colors.black87;

    TextStyle getStyle(Color col) => TextStyle(
      color: col,
      fontSize: fontSize ?? 24,
      fontFamily: selectedFont,
      fontWeight: FontWeight.w900, // Force extra bold for Indo-Pak look
      height: 1.15, // Tighter vertical spacing like in the screenshot
      letterSpacing: -0.2,
    );

    if (!text.contains('[')) return _parseCanonicalUthmani(text, getStyle(resolvedColor), resolvedColor, showTajweed);

    if (!showTajweed) {
      String clean = text;
      while (clean.contains(RegExp(r'\[[a-zA-Z]+:?\d*\['))) {
        clean = clean.replaceAllMapped(RegExp(r'\[[a-zA-Z]+:?\d*\[([^\[\]]+)\]+'), (m) => m.group(1) ?? '');
      }
      clean = clean.replaceAll('[', '').replaceAll(']', '').replaceAll(RegExp(r'<[^>]*>'), '').replaceAll('\u0672', '\u0670').replaceAll('\u0640\u0670', '\u0670');
      return [TextSpan(text: clean, style: getStyle(resolvedColor))];
    }

    String str = text.replaceAll(RegExp(r'<[^>]*>'), '').replaceAll('\u0672', '\u0670').replaceAll('\u0640\u0670', '\u0670');
    final RegExp tagRegex = RegExp(r'\[([a-zA-Z]+):?\d*\[([^\]]+)\]+');
    final matches = tagRegex.allMatches(str);
    final List<_SpanToken> tokens = [];
    int index = 0;

    for (final match in matches) {
      if (match.start > index) {
        String plain = str.substring(index, match.start).replaceAll('[', '').replaceAll(']', '');
        if (plain.isNotEmpty) tokens.add(_SpanToken(plain, resolvedColor));
      }
      String rule = match.group(1)?.toLowerCase() ?? '';
      String content = (match.group(2) ?? '').replaceAll('[', '').replaceAll(']', '');
      if (content.isNotEmpty) tokens.add(_SpanToken(content, _tajweedColors[rule] ?? resolvedColor));
      index = match.end;
    }
    if (index < str.length) {
      String remaining = str.substring(index).replaceAll('[', '').replaceAll(']', '');
      if (remaining.isNotEmpty) tokens.add(_SpanToken(remaining, resolvedColor));
    }

    for (int i = tokens.length - 1; i >= 1; i--) {
      final current = tokens[i];
      if (current.text.isEmpty) continue;
      int prefixCombiningLen = 0;
      while (prefixCombiningLen < current.text.length && isArabicCombiningMark(current.text.codeUnitAt(prefixCombiningLen))) prefixCombiningLen++;
      if (prefixCombiningLen > 0) {
        tokens[i - 1].text += current.text.substring(0, prefixCombiningLen);
        current.text = current.text.substring(prefixCombiningLen);
      }
    }

    final List<_SpanToken> merged = [];
    for (final tok in tokens) {
      if (tok.text.isEmpty) continue;
      if (merged.isNotEmpty && merged.last.color == tok.color) merged.last.text += tok.text;
      else merged.add(tok);
    }

    return merged.map((t) => TextSpan(text: t.text, style: getStyle(t.color ?? resolvedColor))).toList();
  }
}
