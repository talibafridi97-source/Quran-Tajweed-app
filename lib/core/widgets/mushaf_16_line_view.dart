import 'package:flutter/material.dart';
import '../../models/mushaf_16_line_model.dart';
import '../../core/constants/constants.dart';
import '../../core/utils/tajweed_parser.dart';
import '../../services/audio_manager_service.dart';

/// Professional Indo-Pak 16-Line Mushaf Page View.
/// Redesigned with precise Para-start highlighting (Sirf Line 1).
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

  @override
  Widget build(BuildContext context) {
    final audioManager = AudioManagerService.instance;
    final bool isSpecialPage = page.pageNumber >= 2 && page.pageNumber <= 3;

    return AnimatedBuilder(
      animation: audioManager,
      builder: (context, _) {
        final currentSurah = audioManager.currentSurahNumber;
        final currentAyah = audioManager.currentAyahNumber;
        final activeVerseKey = (audioManager.isPlaying || audioManager.isPaused) && currentSurah != null && currentAyah != null
            ? (audioManager.isBismillah ? '$currentSurah:0' : '$currentSurah:$currentAyah') 
            : null;

        return Column(
          children: List.generate(16, (index) {
            final line = index < page.lines.length ? page.lines[index] : null;
            final bool isParaStart = line?.isParaStart ?? false;

            return Expanded(
              flex: (line?.isSurahHeader == true && isSpecialPage) ? 3 : 1,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  // VIBRANT Solid Gold background for ONLY the start line (Line 1 of Para)
                  color: isParaStart ? const Color(0xFFFFD700) : null,
                  border: Border(
                    bottom: BorderSide(
                      color: isParaStart ? const Color(0xFFFFD700) : const Color(0x15000000), 
                      width: isParaStart ? 1.0 : 0.5,
                    ),
                  ),
                ),
                child: line != null 
                    ? _buildLineSlot(context, line, activeVerseKey, isSpecialPage)
                    : const SizedBox.shrink(),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildLineSlot(BuildContext context, Mushaf16Line line, String? activeKey, bool isSpecial) {
    if (line.isSurahHeader) return _buildHeader(context, line.surahName, line.surahNumber, isLarge: isSpecial);
    if (line.isBismillah) return _buildBismillah(context, isActive: activeKey == '${line.surahNumber}:0', isLarge: isSpecial);
    if (line.isEmpty) return const SizedBox.shrink();

    return _buildJustifiedRow(context, line, activeKey);
  }

  Widget _buildJustifiedRow(BuildContext context, Mushaf16Line line, String? activeKey) {
    final audioManager = AudioManagerService.instance;
    
    // Para Start styling: Force ULTRA bold and SOLID RED color for the starting line
    final bool isParaStart = line.isParaStart;
    final Color textColor = isParaStart ? const Color(0xFFD32F2F) : const Color(0xFF14171A);
    final FontWeight weight = isParaStart ? FontWeight.w900 : FontWeight.w800;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.center,
        child: SizedBox(
          width: 480, 
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween, 
            textDirection: TextDirection.rtl,
            children: line.segments.map((seg) {
              final active = activeKey != null && seg.verseKey == activeKey;

              Widget w;
              if (seg.isAyahEnd) {
                w = Text(
                  seg.text, 
                  style: TextStyle(
                    color: isParaStart ? const Color(0xFFD32F2F) : AppConstants.gold, 
                    fontSize: fontSize * (isParaStart ? 1.0 : 0.9), 
                    fontWeight: FontWeight.bold, 
                    fontFamily: fontFamily, 
                    backgroundColor: active ? const Color(0x44D4AF37) : null
                  )
                );
              } else {
                final spans = TajweedParser.parse(
                  seg.text, 
                  fontSize: isParaStart ? fontSize * 1.1 : fontSize, 
                  fontFamily: fontFamily, 
                  defaultColor: textColor, 
                  showTajweed: showTajweed
                );
                
                final styled = spans.map((s) {
                  if (s is TextSpan) {
                    return TextSpan(
                      text: s.text,
                      style: s.style?.copyWith(
                        fontWeight: weight,
                        color: isParaStart ? textColor : s.style?.color,
                        backgroundColor: active ? const Color(0x44D4AF37) : null,
                      ),
                    );
                  }
                  return s;
                }).toList();
                
                w = Text.rich(
                  TextSpan(children: styled), 
                  textDirection: TextDirection.rtl, 
                  textAlign: TextAlign.center, 
                  maxLines: 1,
                );
              }

              return GestureDetector(
                onTap: () => audioManager.playAyah(surahNumber: seg.surahNumber, ayahNumber: seg.ayahNumberInSurah, surahName: line.surahName),
                child: w,
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String name, int sNum, {bool isLarge = false}) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(vertical: 4, horizontal: isLarge ? 20 : 10),
      height: isLarge ? 80 : 45,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFF1E6B5C), width: isLarge ? 2.5 : 1.5), boxShadow: [BoxShadow(color: const Color(0xFFD4AF37).withValues(alpha: 0.2), blurRadius: 4)]),
      child: Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        _meta('آياتُها', sNum == 1 ? '۷' : (sNum == 2 ? '۲۸۶' : '---')),
        Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text('سُورَةُ', style: TextStyle(fontFamily: fontFamily, fontSize: isLarge ? 12 : 9, color: const Color(0xFF1E6B5C), fontWeight: FontWeight.bold)),
          Text(name, style: TextStyle(fontFamily: fontFamily, fontSize: isLarge ? 28 : 18, fontWeight: FontWeight.bold, color: const Color(0xFF0D3B2E))),
        ])),
        _meta('رُكوعاتها', sNum == 1 ? '۱' : (sNum == 2 ? '۴۰' : '---')),
      ])),
    );
  }

  Widget _meta(String l, String v) => Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: const Color(0xFFF7F2E6), borderRadius: BorderRadius.circular(4), border: Border.all(color: const Color(0xFFFFD700), width: 0.8)), child: Column(mainAxisSize: MainAxisSize.min, children: [
    Text(l, style: const TextStyle(fontSize: 7, fontWeight: FontWeight.bold, color: Color(0xFF1E6B5C))),
    Text(v, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
  ]));

  Widget _buildBismillah(BuildContext context, {bool isActive = false, bool isLarge = false}) {
    return Container(margin: EdgeInsets.symmetric(vertical: 4, horizontal: isLarge ? 30 : 0), decoration: BoxDecoration(color: isActive ? const Color(0x22D4AF37) : const Color(0xFFFCFAF5), border: const Border.symmetric(horizontal: BorderSide(color: Color(0xFFD4AF37), width: 1.2))), child: Center(child: FittedBox(fit: BoxFit.scaleDown, child: Text('بِسْمِ اللهِ الرَّحْمٰنِ الرَّحِيمِ', style: TextStyle(fontFamily: AppConstants.uthmaniFont, fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0D3B2E))))));
  }
}
