import 'package:flutter/material.dart';
import '../../models/mushaf_16_line_model.dart';
import '../../core/constants/constants.dart';
import '../../core/utils/tajweed_parser.dart';
import '../../services/audio_manager_service.dart';

/// Professional Indo-Pak 16-Line Mushaf Page View.
/// Redesigned for maximum "Pakistani Tajweed Quran" fidelity:
/// - Extra thick (mota) script.
/// - Vibrant Tajweed coloring.
/// - Perfect vertical centering.
class Mushaf16LineView extends StatelessWidget {
  final Mushaf16LinePage page;
  final double fontSize;
  final String fontFamily;
  final bool showTajweed;
  final Function(int surahNumber, int ayahNumber)? onAyahTap;

  const Mushaf16LineView({
    super.key,
    required this.page,
    this.fontSize = 36.0, // Increased default for thicker look
    this.fontFamily = AppConstants.uthmaniFont,
    this.showTajweed = true,
    this.onAyahTap,
  });

  @override
  Widget build(BuildContext context) {
    final audioManager = AudioManagerService.instance;
    final bool isSpecialHeaderPage = page.pageNumber >= 2 && page.pageNumber <= 3;

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
            final bool isStart = line?.isParaStart ?? false;

            // Flex distribution for vertical balance
            int flexVal = 1;
            if (line?.isSurahHeader == true) flexVal = isSpecialHeaderPage ? 3 : 2;
            else if (line?.isBismillah == true) flexVal = 2;

            return Expanded(
              flex: flexVal,
              child: Container(
                width: double.infinity,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isStart ? const Color(0xFFFFD700).withValues(alpha: 0.1) : null,
                  border: const Border(bottom: BorderSide(color: Color(0x0F000000), width: 0.5)),
                ),
                child: line != null 
                    ? _buildLineSlot(context, line, activeVerseKey, isSpecialHeaderPage)
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
    if (line.isBismillah) return _buildBismillah(context, isActive: activeKey == '${line.surahNumber}:0');
    if (line.isEmpty) return const SizedBox.shrink();

    return _buildProfessionalJustifiedLine(context, line, activeKey);
  }

  Widget _buildProfessionalJustifiedLine(BuildContext context, Mushaf16Line line, String? activeKey) {
    final audioManager = AudioManagerService.instance;
    final bool isStart = line.isParaStart;
    final Color textColor = isStart ? const Color(0xFF1B5E20) : const Color(0xFF000000); // Black for high contrast
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: FittedBox(
        fit: BoxFit.contain,
        alignment: Alignment.center,
        child: SizedBox(
          width: 700, // Wide logical width for smooth bold rendering
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
                    color: AppConstants.gold, 
                    fontSize: fontSize * 0.95, 
                    fontWeight: FontWeight.w900, 
                    fontFamily: fontFamily, 
                    backgroundColor: active ? const Color(0x44D4AF37) : null
                  )
                );
              } else {
                final spans = TajweedParser.parse(
                  seg.text, 
                  fontSize: fontSize, 
                  fontFamily: fontFamily, 
                  defaultColor: textColor, 
                  showTajweed: showTajweed
                );
                
                final styled = spans.map((s) {
                  if (s is TextSpan) {
                    return TextSpan(
                      text: s.text, 
                      style: s.style?.copyWith(
                        fontWeight: FontWeight.w900, // Forced Extra Bold for Indo-Pak look
                        height: 1.0, 
                        leadingDistribution: TextLeadingDistribution.even,
                        backgroundColor: active ? const Color(0x44D4AF37) : null,
                      )
                    );
                  }
                  return s;
                }).toList();
                
                w = Text.rich(
                  TextSpan(children: styled), 
                  textDirection: TextDirection.rtl, 
                  textAlign: TextAlign.center, 
                  maxLines: 1,
                  strutStyle: const StrutStyle(forceStrutHeight: true, height: 1.1, leading: 0),
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
      margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(6), 
        border: Border.all(color: const Color(0xFF1E6B5C), width: isLarge ? 2.5 : 1.5), 
        boxShadow: [BoxShadow(color: const Color(0xFFD4AF37).withValues(alpha: 0.15), blurRadius: 4)]
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween, 
            children: [
              _meta('آياتُها', sNum == 1 ? '۷' : (sNum == 2 ? '۲۸۶' : '---')),
              const SizedBox(width: 30),
              Column(
                mainAxisAlignment: MainAxisAlignment.center, 
                children: [
                  Text('سُورَةُ', style: TextStyle(fontFamily: fontFamily, fontSize: 11, color: const Color(0xFF1E6B5C), fontWeight: FontWeight.bold)),
                  Text(name, style: TextStyle(fontFamily: fontFamily, fontSize: 26, fontWeight: FontWeight.w900, color: const Color(0xFF0D3B2E))),
                ]
              ),
              const SizedBox(width: 30),
              _meta('رُكوعاتها', sNum == 1 ? '۱' : (sNum == 2 ? '۴۰' : '---')),
            ]
          ),
        ),
      ),
    );
  }

  Widget _meta(String l, String v) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), 
    decoration: BoxDecoration(color: const Color(0xFFF7F2E6), borderRadius: BorderRadius.circular(4), border: Border.all(color: const Color(0xFFD4AF37), width: 0.8)), 
    child: Column(
      mainAxisSize: MainAxisSize.min, 
      children: [
        Text(l, style: const TextStyle(fontSize: 7, fontWeight: FontWeight.bold, color: Color(0xFF1E6B5C))),
        Text(v, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900)),
      ]
    )
  );

  Widget _buildBismillah(BuildContext context, {bool isActive = false}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 30), 
      decoration: BoxDecoration(
        color: isActive ? const Color(0x22D4AF37) : const Color(0xFFFCFAF5), 
        border: const Border.symmetric(horizontal: BorderSide(color: Color(0xFFD4AF37), width: 1.0))
      ), 
      child: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            'بِسْمِ اللهِ الرَّحْمٰنِ الرَّحِيمِ', 
            style: TextStyle(fontFamily: AppConstants.uthmaniFont, fontSize: 26, fontWeight: FontWeight.w900, color: const Color(0xFF0D3B2E)),
            textAlign: TextAlign.center,
          ),
        )
      )
    );
  }
}
