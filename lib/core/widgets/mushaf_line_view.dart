import 'package:flutter/material.dart';
import '../../models/quran_word.dart';
import '../../services/qcf_font_manager.dart';
import '../constants/constants.dart';

class MushafLineView extends StatelessWidget {
  final int pageNumber;
  final int lineNumber;
  final List<QuranWord> words;
  final double fontSize;

  const MushafLineView({
    super.key,
    required this.pageNumber,
    required this.lineNumber,
    required this.words,
    this.fontSize = 21.0,
  });

  @override
  Widget build(BuildContext context) {
    if (words.isEmpty) {
      return const SizedBox(height: 28);
    }

    final fontFamily = QcfFontManager.getFontFamily(pageNumber);

    // Build the QCF V2 glyph line string in natural RTL order
    final lineGlyphs = words.map((w) => w.codeV2 ?? '').join('');

    return Container(
      height: 32,
      alignment: Alignment.center,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.center,
        child: Text(
          lineGlyphs,
          textDirection: TextDirection.rtl,
          textAlign: TextAlign.center,
          maxLines: 1,
          style: TextStyle(
            fontFamily: fontFamily,
            fontSize: fontSize,
            color: const Color(0xFF14171A),
            fontWeight: FontWeight.normal,
            letterSpacing: 0.0,
            height: 1.0,
          ),
        ),
      ),
    );
  }
}
