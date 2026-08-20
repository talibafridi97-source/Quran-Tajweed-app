import 'package:flutter/material.dart';
import '../constants/constants.dart';

class _SpanToken {
  String text;
  Color? color;
  _SpanToken(this.text, this.color);
}

class TajweedParser {
  static const Map<String, Color> _tajweedColors = {
    // Silent & Wasl (Muted Slate Gray)
    'h': Color(0xFF8A9096), // Hamzatul Wasl
    's': Color(0xFF8A9096), // Silent letter
    'l': Color(0xFF8A9096), // Lam Shamsiyyah
    
    // Ghunnah (Vibrant Orange)
    'n': Color(0xFFE65100), // Ghunnah
    'g': Color(0xFFE65100), // Ghunnah (alternate)

    // Idgham (Emerald Green)
    'm': Color(0xFF00897B), // Idgham
    'u': Color(0xFF00897B), // Idgham Shafawi
    'a': Color(0xFF00897B), // Idgham / Alif
    'r': Color(0xFF00897B), // Idgham without Ghunnah

    // Iqlab (Sky Cyan)
    'b': Color(0xFF00B0FF), // Iqlab
    'd': Color(0xFF00B0FF), // Iqlab (alternate)
    'v': Color(0xFF00B0FF), // Iqlab (alternate)

    // Ikhfa (Royal Purple / Magenta)
    'i': Color(0xFF8E24AA), // Ikhfa
    'p': Color(0xFF8E24AA), // Ikhfa Shafawi
    'c': Color(0xFF8E24AA), // Ikhfa (alternate)
    'f': Color(0xFF8E24AA), // Ikhfa Shafawi (alternate)

    // Qalqalah (Electric Azure / Blue)
    'q': Color(0xFF0288D1), // Qalqalah

    // Madds (Crimson / Magenta Tones)
    'w': Color(0xFFC2185B), // Madd 6 Harakat (Dark Magenta)
    'o': Color(0xFFD81B60), // Madd 4-5 Harakat (Vibrant Magenta)
    'j': Color(0xFFE91E63), // Madd 2 Harakat (Bright Pink)
  };

  /// Returns true if the Unicode code unit is an Arabic non-spacing combining mark.
  static bool isArabicCombiningMark(int codeUnit) {
    return (codeUnit >= 0x0610 && codeUnit <= 0x061A) ||
        (codeUnit >= 0x064B && codeUnit <= 0x065F) ||
        codeUnit == 0x0670 ||
        (codeUnit >= 0x06D6 && codeUnit <= 0x06DC) ||
        (codeUnit >= 0x06DF && codeUnit <= 0x06E4) ||
        (codeUnit >= 0x06E7 && codeUnit <= 0x06E8) ||
        (codeUnit >= 0x06EA && codeUnit <= 0x06ED) ||
        (codeUnit >= 0x08D4 && codeUnit <= 0x08E1) ||
        (codeUnit >= 0x08E3 && codeUnit <= 0x08FF);
  }

  // Split authentic string into Grapheme Clusters
  static List<String> toGraphemeClusters(String text) {
    List<String> clusters = [];
    StringBuffer current = StringBuffer();

    for (int i = 0; i < text.length; i++) {
      int cu = text.codeUnitAt(i);
      if (isArabicCombiningMark(cu)) {
        current.writeCharCode(cu);
      } else {
        if (current.isNotEmpty) {
          clusters.add(current.toString());
          current.clear();
        }
        current.writeCharCode(cu);
      }
    }
    if (current.isNotEmpty) {
      clusters.add(current.toString());
    }
    return clusters;
  }

  static List<InlineSpan> _parseCanonicalUthmani(
    String text,
    TextStyle style,
    Color resolvedColor,
    bool showTajweed,
  ) {
    if (!showTajweed) {
      return [TextSpan(text: text, style: style)];
    }

    final clusters = toGraphemeClusters(text);
    final List<Color> colors = List.filled(clusters.length, resolvedColor);

    const qalqalahLetters = {'ق', 'ط', 'ب', 'ج', 'د'};
    const ikhfaLetters = {'ت', 'ث', 'ج', 'د', 'ذ', 'ز', 'س', 'ش', 'ص', 'ض', 'ط', 'ظ', 'ف', 'ق', 'ك'};
    const idghamLetters = {'ي', 'ر', 'م', 'ل', 'و', 'ن'};

    bool isTanween(String cl) =>
        cl.contains('\u064B') || cl.contains('\u064C') || cl.contains('\u064D');

    bool isPlainNoonSakinah(String cl) =>
        cl.startsWith('ن') &&
        !cl.contains('\u064E') &&
        !cl.contains('\u0650') &&
        !cl.contains('\u064F') &&
        !cl.contains('\u0651') &&
        !cl.contains('\u0652');

    for (int i = 0; i < clusters.length; i++) {
      final cluster = clusters[i];
      if (cluster.isEmpty) continue;
      final base = cluster[0];

      // 1. Hamzatul Wasl: ٱ (U+0671)
      if (base == '\u0671') {
        colors[i] = _tajweedColors['h'] ?? resolvedColor;
      }
      // 2. Silent Letter: Letter with U+06DF (Small High Rounded Zero ۟) or U+06E0
      else if (cluster.contains('\u06DF') || cluster.contains('\u06E0')) {
        colors[i] = _tajweedColors['s'] ?? resolvedColor;
      }
      // 3. Ghunnah: Noon or Meem with Shadda (ّ U+0651)
      else if ((base == 'ن' || base == 'م') && cluster.contains('\u0651')) {
        colors[i] = _tajweedColors['n'] ?? resolvedColor;
      }
      // 4. Madd: Any letter containing Maddah (ٓ U+0653 or ۤ U+06E4)
      else if (cluster.contains('\u0653') || cluster.contains('\u06E4')) {
        colors[i] = _tajweedColors['o'] ?? resolvedColor;
      }
      // 5. Iqlab: Small Meem (ۢ U+06E2 or ۭ U+06ED)
      else if (cluster.contains('\u06E2') || cluster.contains('\u06ED')) {
        colors[i] = _tajweedColors['b'] ?? resolvedColor;
      }
      // 6. Qalqalah: Qaf, Taa, Baa, Jeem, Dal with Sukun (ْ U+0652 or ۡ U+06E1)
      else if (qalqalahLetters.contains(base) &&
          (cluster.contains('\u0652') || cluster.contains('\u06E1'))) {
        colors[i] = _tajweedColors['q'] ?? resolvedColor;
      }
      // 7. Ikhfa / Idgham on Noon Sakinah or Tanween
      else if (isPlainNoonSakinah(cluster) || isTanween(cluster)) {
        // Look ahead for next non-space cluster
        int nextIdx = i + 1;
        while (nextIdx < clusters.length && clusters[nextIdx].trim().isEmpty) {
          nextIdx++;
        }
        if (nextIdx < clusters.length) {
          final nextBase = clusters[nextIdx].isNotEmpty ? clusters[nextIdx][0] : '';
          if (ikhfaLetters.contains(nextBase)) {
            colors[i] = _tajweedColors['i'] ?? resolvedColor;
          } else if (idghamLetters.contains(nextBase)) {
            colors[i] = _tajweedColors['m'] ?? resolvedColor;
          }
        }
      }
    }

    // Merge consecutive clusters with same color into TextSpans
    final List<InlineSpan> spans = [];
    StringBuffer buffer = StringBuffer();
    Color currentColor = colors.isNotEmpty ? colors[0] : resolvedColor;

    for (int i = 0; i < clusters.length; i++) {
      if (colors[i] == currentColor) {
        buffer.write(clusters[i]);
      } else {
        if (buffer.isNotEmpty) {
          spans.add(TextSpan(
            text: buffer.toString(),
            style: style.copyWith(color: currentColor),
          ));
          buffer.clear();
        }
        currentColor = colors[i];
        buffer.write(clusters[i]);
      }
    }
    if (buffer.isNotEmpty) {
      spans.add(TextSpan(
        text: buffer.toString(),
        style: style.copyWith(color: currentColor),
      ));
    }

    return spans;
  }

  static List<InlineSpan> parse(
    String text, {
    double? fontSize,
    Color? defaultColor,
    String? fontFamily,
    bool showTajweed = true,
  }) {
    final selectedFont = (fontFamily != null && fontFamily.isNotEmpty)
        ? fontFamily
        : AppConstants.uthmaniFont;

    final resolvedColor = defaultColor ?? Colors.black87;

    TextStyle getStyle(Color col) {
      return TextStyle(
        color: col,
        fontSize: fontSize ?? 24,
        fontFamily: selectedFont,
        fontWeight: FontWeight.normal,
        height: 2.05,
        letterSpacing: 0.0,
      );
    }

    // If pure canonical Uthmani text (no tags present), parse via pure grapheme cluster engine
    if (!text.contains('[')) {
      return _parseCanonicalUthmani(text, getStyle(resolvedColor), resolvedColor, showTajweed);
    }

    if (!showTajweed) {
      String clean = text;
      while (clean.contains(RegExp(r'\[[a-zA-Z]+:?\d*\['))) {
        clean = clean.replaceAllMapped(
          RegExp(r'\[[a-zA-Z]+:?\d*\[([^\[\]]+)\]+'),
          (m) => m.group(1) ?? '',
        );
      }
      clean = clean
          .replaceAll('[', '')
          .replaceAll(']', '')
          .replaceAll(RegExp(r'<[^>]*>'), '')
          .replaceAll('\u0672', '\u0670')
          .replaceAll('\u0640\u0670', '\u0670');
      return [TextSpan(text: clean, style: getStyle(resolvedColor))];
    }

    // Clean XML tags if present
    String str = text.replaceAll(RegExp(r'<[^>]*>'), '');
    // Canonicalize legacy transcription artifacts
    str = str.replaceAll('\u0672', '\u0670').replaceAll('\u0640\u0670', '\u0670');

    // Robust regex to capture Al-Quran Cloud Tajweed format: [rule:id[text]]
    final RegExp tagRegex = RegExp(r'\[([a-zA-Z]+):?\d*\[([^\]]+)\]+');
    final matches = tagRegex.allMatches(str);

    final List<_SpanToken> tokens = [];
    int index = 0;

    for (final match in matches) {
      // Plain text before the tag
      if (match.start > index) {
        String plain = str.substring(index, match.start).replaceAll('[', '').replaceAll(']', '');
        if (plain.isNotEmpty) {
          tokens.add(_SpanToken(plain, resolvedColor));
        }
      }

      String rule = match.group(1)?.toLowerCase() ?? '';
      String content = (match.group(2) ?? '').replaceAll('[', '').replaceAll(']', '');

      if (content.isNotEmpty) {
        Color color = _tajweedColors[rule] ?? resolvedColor;
        tokens.add(_SpanToken(content, color));
      }

      index = match.end;
    }

    // Remaining text after last match
    if (index < str.length) {
      String remaining = str.substring(index).replaceAll('[', '').replaceAll(']', '');
      if (remaining.isNotEmpty) {
        tokens.add(_SpanToken(remaining, resolvedColor));
      }
    }

    // --- Grapheme Cluster Consolidation Pass ---
    // Ensure NO span begins with an orphaned combining mark.
    // Any leading combining mark belongs to the preceding base consonant.
    for (int i = tokens.length - 1; i >= 1; i--) {
      final current = tokens[i];
      if (current.text.isEmpty) continue;

      int prefixCombiningLen = 0;
      while (prefixCombiningLen < current.text.length &&
          isArabicCombiningMark(current.text.codeUnitAt(prefixCombiningLen))) {
        prefixCombiningLen++;
      }

      if (prefixCombiningLen > 0) {
        String orphanedMarks = current.text.substring(0, prefixCombiningLen);
        tokens[i - 1].text += orphanedMarks;
        current.text = current.text.substring(prefixCombiningLen);
      }
    }

    // Merge consecutive tokens of the same color and eliminate empty tokens
    final List<_SpanToken> mergedTokens = [];
    for (final tok in tokens) {
      if (tok.text.isEmpty) continue;
      if (mergedTokens.isNotEmpty && mergedTokens.last.color == tok.color) {
        mergedTokens.last.text += tok.text;
      } else {
        mergedTokens.add(tok);
      }
    }

    // Ensure first token does not start with an unattached mark
    if (mergedTokens.isNotEmpty && mergedTokens.first.text.isNotEmpty) {
      while (mergedTokens.first.text.isNotEmpty &&
          isArabicCombiningMark(mergedTokens.first.text.codeUnitAt(0))) {
        mergedTokens.first.text = mergedTokens.first.text.substring(1);
      }
    }

    // Build final TextSpans
    List<InlineSpan> spans = [];
    for (final tok in mergedTokens) {
      if (tok.text.isNotEmpty) {
        spans.add(TextSpan(
          text: tok.text,
          style: getStyle(tok.color ?? resolvedColor),
        ));
      }
    }

    return spans;
  }
}

