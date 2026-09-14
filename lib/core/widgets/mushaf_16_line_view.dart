import 'package:flutter/material.dart';
import '../../models/mushaf_16_line_model.dart';
import '../../core/constants/constants.dart';
import '../../core/utils/tajweed_parser.dart';
import '../../services/audio_manager_service.dart';

/// High-Fidelity Reproduction of the 16-Line Tajweed Quran Standard.
/// Strictly follows Pakistani Indo-Pak calligraphy aesthetics (Taj Company Standard).
class Mushaf16LineView extends StatelessWidget {
  final Mushaf16LinePage page;
  final double fontSize;
  final String fontFamily;
  final bool showTajweed;
  final Function(int surahNumber, int ayahNumber)? onAyahTap;

  const Mushaf16LineView({
    super.key,
    required this.page,
    this.fontSize = 32.0, 
    this.fontFamily = AppConstants.uthmaniFont,
    this.showTajweed = true,
    this.onAyahTap,
  });

  @override
  Widget build(BuildContext context) {
    final audioManager = AudioManagerService.instance;
    final bool isSpecialPage = page.pageNumber == 2 || page.pageNumber == 3;

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
            
            // Flex distribution: Headers and Bismillah get more breathing space
            int flexVal = 1;
            if (line?.isSurahHeader == true) flexVal = isSpecialPage ? 4 : 3;
            else if (line?.isBismillah == true) flexVal = 2;

            return Expanded(
              flex: flexVal,
              child: Container(
                width: double.infinity,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  // Horizontal row separators like in the Pakistani printed Mushaf
                  border: Border(bottom: BorderSide(color: Color(0x1A000000), width: 0.6)),
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
    if (line.isSurahHeader) return _buildAuthenticHeader(context, line.surahName, line.surahNumber, isLarge: isSpecial);
    if (line.isBismillah) return _buildAuthenticBismillah(context, isActive: activeKey == '${line.surahNumber}:0');
    if (line.isEmpty) return const SizedBox.shrink();

    return _buildJustifiedIndoPakLine(context, line, activeKey);
  }

  Widget _buildJustifiedIndoPakLine(BuildContext context, Mushaf16Line line, String? activeKey) {
    final audioManager = AudioManagerService.instance;
    const Color textColor = Colors.black;
    final isParaStart = line.isParaStart;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: isParaStart ? BoxDecoration(
        color: AppConstants.gold.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppConstants.gold.withValues(alpha: 0.5), width: 1.0),
      ) : null,
      child: FittedBox(
        fit: BoxFit.contain,
        alignment: Alignment.center,
        child: SizedBox(
          width: 800, // Forces Edge-to-Edge Justification
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
                        fontWeight: FontWeight.w900, // Extra Mota (Bold) script
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
                  strutStyle: const StrutStyle(forceStrutHeight: true, height: 1.5, leading: 0.2),
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

  Widget _buildAuthenticHeader(BuildContext context, String name, int sNum, {bool isLarge = false}) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(vertical: 2, horizontal: isLarge ? 12 : 8),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(4), 
        border: Border.all(color: const Color(0xFF1E6B5C), width: isLarge ? 2.5 : 1.5), 
        boxShadow: [BoxShadow(color: const Color(0xFFD4AF37).withValues(alpha: 0.15), blurRadius: 4)]
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, 
        children: [
          _metaBox('آياتُها', sNum == 1 ? '۷' : (sNum == 2 ? '۲۸۶' : '---')),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center, 
              children: [
                Text('سُورَةُ', style: TextStyle(fontFamily: fontFamily, fontSize: isLarge ? 11 : 8, color: const Color(0xFF1E6B5C), fontWeight: FontWeight.bold)),
                Text(name, style: TextStyle(fontFamily: fontFamily, fontSize: isLarge ? 28 : 20, fontWeight: FontWeight.w900, color: const Color(0xFF0D3B2E))),
              ]
            )
          ),
          _metaBox('رُكوعاتها', sNum == 1 ? '۱' : (sNum == 2 ? '۴۰' : '---')),
        ]
      ),
    );
  }

  Widget _metaBox(String l, String v) => Container(
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

  Widget _buildAuthenticBismillah(BuildContext context, {bool isActive = false}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 24), 
      decoration: BoxDecoration(
        color: isActive ? const Color(0x22D4AF37) : const Color(0xFFFCFAF5), 
        border: const Border.symmetric(horizontal: BorderSide(color: Color(0xFFD4AF37), width: 1.0))
      ), 
      child: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            'بِسْمِ اللهِ الرَّحْمٰنِ الرَّحِيمِ', 
            style: TextStyle(fontFamily: AppConstants.uthmaniFont, fontSize: 24, fontWeight: FontWeight.w900, color: const Color(0xFF0D3B2E)),
            textAlign: TextAlign.center,
          ),
        )
      )
    );
  }
}
