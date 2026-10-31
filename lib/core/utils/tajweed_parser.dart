import 'package:flutter/material.dart';
import '../constants/constants.dart';

class _SpanToken {
  String text;
  Color? color;
  _SpanToken(this.text, this.color);
}

class TajweedParser {
  /// Pakistani rangeen mushaf colors (Taj Company / 16-line style).
  static const Map<String, Color> _tajweedColors = {
    // Silent, Hamzatul Wasl, Lam Shamsiyyah
    'h': Color(0xFF9E9E9E),
    's': Color(0xFF9E9E9E),
    'l': Color(0xFF9E9E9E),

    // Ghunnah — orange
    'n': Color(0xFFFF8F00),
    'g': Color(0xFFFF6D00),

    // Madd — red
    'm': Color(0xFFE53935),
    'p': Color(0xFFD32F2F),
    'o': Color(0xFFB71C1C),
    'w': Color(0xFFC62828),
    'j': Color(0xFFEF5350),

    // Qalqalah — blue
    'q': Color(0xFF1565C0),

    // Ikhfa — pink / magenta
    'f': Color(0xFFD81B60),
    'i': Color(0xFFC2185B),
    'c': Color(0xFFAD1457),

    // Idgham — green
    'u': Color(0xFF2E7D32),
    'a': Color(0xFF43A047),
    'r': Color(0xFF1B5E20),
    'e': Color(0xFF388E3C),

    // Iqlab — sky blue
    'b': Color(0xFF00B0FF),
    'd': Color(0xFF0288D1),
  };

  static final RegExp tajweedTag = RegExp(r'\[([a-zA-Z]+):?\d*\[([^\]]*)\]+');

  static String toArabicDigits(int number) {
    const arabicDigits = ['۰', '۱', '۲', '۳', '۴', '٥', '٦', '۷', '۸', '۹'];
    return number.toString().split('').map((digit) {
      final idx = int.tryParse(digit);
      return idx != null ? arabicDigits[idx] : digit;
    }).join();
  }

  static bool hasMarkup(String text) => text.contains('[');

  static String stripMarkup(String text) {
    if (!text.contains('[')) return text;
    return text.replaceAllMapped(tajweedTag, (m) => m.group(2) ?? '').replaceAll('[', '').replaceAll(']', '');
  }

  /// Keep spaces that live inside tajweed tags so word-splitting does not break coloring.
  static String protectTaggedSpaces(String text) {
    if (!text.contains('[')) return text;
    return text.replaceAllMapped(tajweedTag, (m) => m[0]!.replaceAll(' ', '\u00A0'));
  }

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
    const idghamWithGhunnah = {'ي', 'ن', 'م', 'و'};
    const idghamWithoutGhunnah = {'ر', 'ل'};

    bool isTanween(String cl) => cl.contains('\u064B') || cl.contains('\u064C') || cl.contains('\u064D');
    bool isPlainNoonSakinah(String cl) =>
        cl.startsWith('ن') &&
        !cl.contains('\u064E') &&
        !cl.contains('\u0650') &&
        !cl.contains('\u064F') &&
        !cl.contains('\u0651') &&
        !cl.contains('\u0652');
    bool isPlainMeemSakinah(String cl) =>
        cl.startsWith('م') &&
        !cl.contains('\u064E') &&
        !cl.contains('\u0650') &&
        !cl.contains('\u064F') &&
        !cl.contains('\u0651');

    String? nextBase(int from) {
      int nextIdx = from + 1;
      while (nextIdx < clusters.length && clusters[nextIdx].trim().isEmpty) {
        nextIdx++;
      }
      if (nextIdx >= clusters.length || clusters[nextIdx].isEmpty) return null;
      return clusters[nextIdx][0];
    }

    for (int i = 0; i < clusters.length; i++) {
      final cluster = clusters[i];
      if (cluster.isEmpty) continue;
      final base = cluster[0];
      if (base == '\u0671') {
        colors[i] = _tajweedColors['h']!;
      } else if (cluster.contains('\u06DF') || cluster.contains('\u06E0')) {
        colors[i] = _tajweedColors['s']!;
      } else if ((base == 'ن' || base == 'م') && cluster.contains('\u0651')) {
        colors[i] = _tajweedColors['n']!;
      } else if (cluster.contains('\u0653') || cluster.contains('\u06E4') || cluster.contains('\u06E5')) {
        colors[i] = _tajweedColors['o']!;
      } else if (cluster.contains('\u06E2') || cluster.contains('\u06ED')) {
        colors[i] = _tajweedColors['b']!;
      } else if (qalqalahLetters.contains(base) && (cluster.contains('\u0652') || cluster.contains('\u06E1'))) {
        colors[i] = _tajweedColors['q']!;
      } else if (isPlainNoonSakinah(cluster) || isTanween(cluster)) {
        final next = nextBase(i);
        if (next != null) {
          if (ikhfaLetters.contains(next)) {
            colors[i] = _tajweedColors['f']!;
          } else if (idghamWithGhunnah.contains(next)) {
            colors[i] = _tajweedColors['u']!;
          } else if (idghamWithoutGhunnah.contains(next)) {
            colors[i] = _tajweedColors['a']!;
          } else if (next == 'ب') {
            colors[i] = _tajweedColors['b']!;
          }
        }
      } else if (isPlainMeemSakinah(cluster)) {
        final next = nextBase(i);
        if (next == 'م') {
          colors[i] = _tajweedColors['u']!;
        } else if (next == 'ب') {
          colors[i] = _tajweedColors['c']!;
        }
      }
    }

    final List<InlineSpan> spans = [];
    StringBuffer buffer = StringBuffer();
    Color currentColor = colors.isNotEmpty ? colors[0] : resolvedColor;
    for (int i = 0; i < clusters.length; i++) {
      if (colors[i] == currentColor) {
        buffer.write(clusters[i]);
      } else {
        if (buffer.isNotEmpty) {
          spans.add(TextSpan(text: buffer.toString(), style: style.copyWith(color: currentColor)));
        }
        buffer.clear();
        currentColor = colors[i];
        buffer.write(clusters[i]);
      }
    }
    if (buffer.isNotEmpty) {
      spans.add(TextSpan(text: buffer.toString(), style: style.copyWith(color: currentColor)));
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
    final selectedFont = (fontFamily != null && fontFamily.isNotEmpty) ? fontFamily : AppConstants.indoPakFont;
    final resolvedColor = defaultColor ?? const Color(0xFF1A1A1A);

    TextStyle getStyle(Color col) => TextStyle(
      color: col,
      fontSize: fontSize ?? 24,
      fontFamily: selectedFont,
      fontWeight: FontWeight.w700,
      height: 1.15,
      letterSpacing: -0.2,
    );

    if (!text.contains('[')) {
      return _parseCanonicalUthmani(text, getStyle(resolvedColor), resolvedColor, showTajweed);
    }

    if (!showTajweed) {
      return [TextSpan(text: stripMarkup(text), style: getStyle(resolvedColor))];
    }

    String str = text.replaceAll(RegExp(r'<[^>]*>'), '').replaceAll('\u0672', '\u0670').replaceAll('\u0640\u0670', '\u0670');
    final matches = tajweedTag.allMatches(str);
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
      while (prefixCombiningLen < current.text.length && isArabicCombiningMark(current.text.codeUnitAt(prefixCombiningLen))) {
        prefixCombiningLen++;
      }
      if (prefixCombiningLen > 0) {
        tokens[i - 1].text += current.text.substring(0, prefixCombiningLen);
        current.text = current.text.substring(prefixCombiningLen);
      }
    }

    final List<_SpanToken> merged = [];
    for (final tok in tokens) {
      if (tok.text.isEmpty) continue;
      if (merged.isNotEmpty && merged.last.color == tok.color) {
        merged.last.text += tok.text;
      } else {
        merged.add(tok);
      }
    }

    return merged.map((t) => TextSpan(text: t.text, style: getStyle(t.color ?? resolvedColor))).toList();
  }
}
