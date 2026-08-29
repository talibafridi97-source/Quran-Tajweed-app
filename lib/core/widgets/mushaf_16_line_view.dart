import 'package:flutter/material.dart';
import '../../models/mushaf_16_line_model.dart';
import '../../core/constants/constants.dart';
import '../../core/utils/tajweed_parser.dart';

/// 16-Line Professional Indo-Pak Mushaf View
/// Fully independent text/visual-based Tajweed rendering:
/// Authentic Quran Arabic text, Uthmani script, Harakat/diacritics, Tajweed rules and colors.
/// Zero dependency on audio playback, audio files, or audio synchronization.
class Mushaf16LineView extends StatelessWidget {
  final Mushaf16LinePage page;
  final double fontSize;
  final String fontFamily;
  final bool showTajweed;
  final Function(int surahNumber, int ayahNumber)? onAyahTap;

  const Mushaf16LineView({
    super.key,
    required this.page,
    this.fontSize = 28.0,
    this.fontFamily = AppConstants.uthmaniFont,
    this.showTajweed = true,
    this.onAyahTap,
  });

  TextStyle _getQuranTextStyle(BuildContext context, {Color? color, bool isHeader = false}) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: isHeader ? fontSize * 1.2 : fontSize,
      color: color ?? const Color(0xFF14171A),
      fontWeight: FontWeight.bold,
      height: 1.35,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isStartPage = page.pageNumber <= 2;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isStartPage ? 8 : 2,
        vertical: isStartPage ? 10 : 2,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: List.generate(page.lines.length, (index) {
          final line = page.lines[index];
          return Expanded(
            flex: (line.isSurahHeader || line.isBismillah) ? 2 : 1,
            child: _buildLineSlot(context, line),
          );
        }),
      ),
    );
  }

  Widget _buildLineSlot(BuildContext context, Mushaf16Line line) {
    final bool isStartPage = page.pageNumber <= 2;

    if (line.isSurahHeader) {
      return _buildOrnamentalSurahHeader(
        context, 
        line.surahName, 
        line.surahNumber,
        isLarge: isStartPage,
      );
    }

    if (line.isBismillah) {
      return _buildOrnamentalBismillah(context, isLarge: isStartPage);
    }

    if (line.isEmpty) {
      return const SizedBox.shrink();
    }

    return _buildJustifiedTextLine(context, line);
  }

  Widget _buildJustifiedTextLine(BuildContext context, Mushaf16Line line) {
    final baseStyle = _getQuranTextStyle(context);
    final List<InlineSpan> spans = [];

    for (final seg in line.segments) {
      if (seg.isAyahEnd) {
        spans.add(
          TextSpan(
            text: seg.text,
            style: TextStyle(
              color: const Color(0xFFD4AF37),
              fontSize: fontSize * 0.85,
              fontWeight: FontWeight.bold,
              fontFamily: fontFamily,
            ),
          ),
        );
      } else {
        final wordSpans = TajweedParser.parse(
          seg.text,
          fontSize: fontSize,
          fontFamily: fontFamily,
          defaultColor: baseStyle.color!,
          showTajweed: showTajweed,
        );
        spans.addAll(wordSpans);
        spans.add(const TextSpan(text: ' '));
      }
    }

    return Container(
      alignment: Alignment.center,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text.rich(
          TextSpan(children: spans),
          textDirection: TextDirection.rtl,
          textAlign: TextAlign.center,
          maxLines: 1,
          softWrap: false,
        ),
      ),
    );
  }

  Widget _buildOrnamentalSurahHeader(BuildContext context, String name, int sNum, {bool isLarge = false}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF1E6B5C), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD4AF37).withValues(alpha: 0.2),
            blurRadius: 4,
          )
        ],
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _headerSubBox('آياتُها', sNum == 1 ? '۷' : (sNum == 2 ? '۲۸۶' : '---')),
              Expanded(
                child: Text(
                  'سُورَةُ $name',
                  style: TextStyle(
                    fontFamily: AppConstants.uthmaniFont,
                    fontSize: isLarge ? 24 : 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0D3B2E),
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  softWrap: false,
                ),
              ),
              _headerSubBox('رُكوعاتها', sNum == 1 ? '۱' : (sNum == 2 ? '۴۰' : '---')),
            ],
          ),
        ),
      ),
    );
  }

  Widget _headerSubBox(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F2E6),
        border: Border.all(color: const Color(0xFFD4AF37), width: 1.0),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '$label $value',
        style: const TextStyle(fontFamily: AppConstants.uthmaniFont, fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF0D3B2E)),
        textAlign: TextAlign.center,
        maxLines: 1,
        softWrap: false,
      ),
    );
  }

  Widget _buildOrnamentalBismillah(BuildContext context, {bool isLarge = false}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      decoration: const BoxDecoration(
        color: Color(0xFFFCFAF5),
        border: Border.symmetric(horizontal: BorderSide(color: Color(0xFFD4AF37), width: 1.2)),
      ),
      child: const Center(
        child: Text(
          'بِسْمِ اللهِ الرَّحْمٰنِ الرَّحِيمِ',
          style: TextStyle(
            fontFamily: AppConstants.uthmaniFont,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0D3B2E),
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          softWrap: false,
        ),
      ),
    );
  }
}
