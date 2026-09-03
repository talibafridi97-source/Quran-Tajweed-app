import 'package:flutter/material.dart';
import '../../models/mushaf_16_line_model.dart';
import '../../core/constants/constants.dart';
import '../../core/utils/tajweed_parser.dart';
import '../../services/audio_manager_service.dart';

/// Professional Indo-Pak 16-Line Mushaf Page View.
/// Strictly enforces exactly 16 lines per page with authentic ornamental design.
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

  TextStyle _getAuthenticIndoPakStyle(BuildContext context, {Color? color, bool isHeader = false}) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: isHeader ? fontSize * 1.15 : fontSize,
      color: color ?? const Color(0xFF14171A),
      fontWeight: FontWeight.w900, // Thick Pakistani script style
      height: 1.25, // Accurate Madani Mushaf line height
      letterSpacing: -0.4, // Dense script
      wordSpacing: 2.5, // Natural Arabic gaps
    );
  }

  @override
  Widget build(BuildContext context) {
    final audioManager = AudioManagerService.instance;
    final bool isSpecialPage = page.pageNumber >= 2 && page.pageNumber <= 3;

    return AnimatedBuilder(
      animation: audioManager,
      builder: (context, _) {
        final currentSurah = audioManager.currentSurahNumber;
        final currentAyah = audioManager.currentAyahNumber;
        final isAudioActive = audioManager.currentChannel == AudioChannel.quran &&
            (audioManager.isPlaying || audioManager.isPaused) &&
            currentSurah != null &&
            currentAyah != null;

        final activeVerseKey = isAudioActive 
            ? (audioManager.isBismillah ? '$currentSurah:0' : '$currentSurah:$currentAyah') 
            : null;

        return Column(
          children: List.generate(16, (index) {
            final line = index < page.lines.length ? page.lines[index] : null;
            
            return Expanded(
              flex: (line?.isSurahHeader == true && isSpecialPage) ? 3 : 1,
              child: Container(
                width: double.infinity,
                alignment: Alignment.center,
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

    return _buildJustifiedLine(context, line, activeKey);
  }

  Widget _buildJustifiedLine(BuildContext context, Mushaf16Line line, String? activeKey) {
    final baseStyle = _getAuthenticIndoPakStyle(context);
    final audioManager = AudioManagerService.instance;

    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        textDirection: TextDirection.rtl,
        children: line.segments.map((seg) {
          final active = activeKey != null && seg.verseKey == activeKey;

          Widget w;
          if (seg.isAyahEnd) {
            w = Text(seg.text, style: TextStyle(color: AppConstants.gold, fontSize: fontSize * 0.9, fontWeight: FontWeight.bold, fontFamily: fontFamily, backgroundColor: active ? const Color(0x44D4AF37) : null));
          } else {
            final spans = TajweedParser.parse(seg.text, fontSize: fontSize, fontFamily: fontFamily, defaultColor: const Color(0xFF14171A), showTajweed: showTajweed);
            final styled = active ? spans.map((s) => (s is TextSpan) ? TextSpan(text: s.text, style: s.style?.copyWith(backgroundColor: const Color(0x44D4AF37))) : s).toList() : spans;
            w = Text.rich(TextSpan(children: styled), textDirection: TextDirection.rtl, textAlign: TextAlign.center, maxLines: 1);
          }

          return GestureDetector(
            onTap: () => audioManager.playAyah(surahNumber: seg.surahNumber, ayahNumber: seg.ayahNumberInSurah, surahName: line.surahName),
            child: Padding(padding: const EdgeInsets.symmetric(horizontal: 1.2), child: w),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String name, int sNum, {bool isLarge = false}) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(vertical: 2, horizontal: isLarge ? 24 : 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFF1E6B5C), width: isLarge ? 2.5 : 1.5), boxShadow: [BoxShadow(color: const Color(0xFFD4AF37).withValues(alpha: 0.2), blurRadius: 4)]),
      child: Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        _meta('آياتُها', sNum == 1 ? '۷' : (sNum == 2 ? '۲۸۶' : '---')),
        Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text('سُورَةُ', style: TextStyle(fontFamily: fontFamily, fontSize: isLarge ? 12 : 9, color: const Color(0xFF1E6B5C), fontWeight: FontWeight.bold)),
          Text(name, style: TextStyle(fontFamily: fontFamily, fontSize: isLarge ? 26 : 18, fontWeight: FontWeight.bold, color: const Color(0xFF0D3B2E))),
        ])),
        _meta('رُكوعاتها', sNum == 1 ? '۱' : (sNum == 2 ? '۴۰' : '---')),
      ])),
    );
  }

  Widget _meta(String l, String v) => Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: const Color(0xFFF7F2E6), borderRadius: BorderRadius.circular(4), border: Border.all(color: const Color(0xFFD4AF37), width: 0.8)), child: Column(mainAxisSize: MainAxisSize.min, children: [
    Text(l, style: const TextStyle(fontSize: 7, fontWeight: FontWeight.bold, color: Color(0xFF1E6B5C))),
    Text(v, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
  ]));

  Widget _buildBismillah(BuildContext context, {bool isActive = false, bool isLarge = false}) {
    return Container(margin: EdgeInsets.symmetric(vertical: 2, horizontal: isLarge ? 30 : 0), decoration: BoxDecoration(color: isActive ? const Color(0x22D4AF37) : const Color(0xFFFCFAF5), border: const Border.symmetric(horizontal: BorderSide(color: Color(0xFFD4AF37), width: 1.2))), child: Center(child: Text('بِسْمِ اللهِ الرَّحْمٰنِ الرَّحِيمِ', style: TextStyle(fontFamily: AppConstants.uthmaniFont, fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0D3B2E)))));
  }
}
