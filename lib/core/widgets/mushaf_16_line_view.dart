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

  TextStyle _getQuranTextStyle(BuildContext context, {Color? color, bool isHeader = false}) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: isHeader ? fontSize * 1.15 : fontSize,
      color: color ?? const Color(0xFF14171A),
      fontWeight: FontWeight.bold,
      height: 1.25, // Compact Indo-Pak line height
      letterSpacing: -0.2,
    );
  }

  @override
  Widget build(BuildContext context) {
    final audioManager = AudioManagerService.instance;
    final bool isStartPage = page.pageNumber >= 2 && page.pageNumber <= 3;

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
          mainAxisSize: MainAxisSize.max,
          children: List.generate(16, (index) {
            final line = index < page.lines.length ? page.lines[index] : null;
            
            // Standard Mushaf distribution: Lines are expanded equally
            return Expanded(
              flex: (line?.isSurahHeader == true && isStartPage) ? 2 : 1,
              child: Container(
                width: double.infinity,
                alignment: Alignment.center,
                child: line != null 
                    ? _buildLineSlot(context, line, activeVerseKey, isStartPage)
                    : const SizedBox.shrink(),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildLineSlot(BuildContext context, Mushaf16Line line, String? activeVerseKey, bool isStartPage) {
    if (line.isSurahHeader) {
      return _buildOrnamentalSurahHeader(context, line.surahName, line.surahNumber, isLarge: isStartPage);
    }

    if (line.isBismillah) {
      final activeBismillah = activeVerseKey == '${line.surahNumber}:0';
      return _buildOrnamentalBismillah(context, isActive: activeBismillah, isLarge: isStartPage);
    }

    if (line.isEmpty) {
      return const SizedBox.shrink();
    }

    return _buildProfessionalTextLine(context, line, activeVerseKey);
  }

  Widget _buildProfessionalTextLine(BuildContext context, Mushaf16Line line, String? activeVerseKey) {
    final baseStyle = _getQuranTextStyle(context);
    final audioManager = AudioManagerService.instance;

    return Stack(
      alignment: Alignment.center,
      children: [
        // Subtle Para start side-badge (integrated into line)
        if (line.isParaStart)
          Positioned(
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: const BoxDecoration(
                color: Color(0x22D4AF37),
                border: Border(right: BorderSide(color: AppConstants.gold, width: 2)),
              ),
              child: Text(
                'PARA ${line.juzNumber}',
                style: const TextStyle(fontSize: 7, fontWeight: FontWeight.bold, color: Color(0xFF7A6538)),
              ),
            ),
          ),

        FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            textDirection: TextDirection.rtl,
            children: line.segments.map((seg) {
              final isSegmentActive = activeVerseKey != null && seg.verseKey == activeVerseKey;

              Widget segmentWidget;
              if (seg.isAyahEnd) {
                segmentWidget = Text(
                  seg.text,
                  style: TextStyle(
                    color: AppConstants.gold,
                    fontSize: fontSize * 0.85,
                    fontWeight: FontWeight.bold,
                    fontFamily: fontFamily,
                    backgroundColor: isSegmentActive ? const Color(0x44D4AF37) : null,
                  ),
                );
              } else {
                final wordSpans = TajweedParser.parse(
                  seg.text,
                  fontSize: fontSize,
                  fontFamily: fontFamily,
                  defaultColor: const Color(0xFF14171A),
                  showTajweed: showTajweed,
                );

                final styledSpans = isSegmentActive
                    ? wordSpans.map((s) {
                        if (s is TextSpan) {
                          return TextSpan(
                            text: s.text,
                            style: s.style?.copyWith(backgroundColor: const Color(0x44D4AF37)),
                          );
                        }
                        return s;
                      }).toList()
                    : wordSpans;

                segmentWidget = Text.rich(
                  TextSpan(children: styledSpans),
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                );
              }

              return GestureDetector(
                onTap: () {
                  audioManager.playAyah(
                    surahNumber: seg.surahNumber,
                    ayahNumber: seg.ayahNumberInSurah,
                    surahName: line.surahName,
                  );
                  onAyahTap?.call(seg.surahNumber, seg.ayahNumberInSurah);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 1.5),
                  child: segmentWidget,
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildOrnamentalSurahHeader(BuildContext context, String name, int sNum, {bool isLarge = false}) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(vertical: 2, horizontal: isLarge ? 20 : 8),
      height: isLarge ? 70 : 45,
      decoration: BoxDecoration(
        color: const Color(0xFFF7F2E6),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFF1E6B5C), width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _headerMetaBox('آیاتُها', sNum == 1 ? '۷' : (sNum == 2 ? '۲۸۶' : '---')),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'سُورَةُ',
                    style: TextStyle(
                      fontFamily: AppConstants.uthmaniFont,
                      fontSize: isLarge ? 12 : 9,
                      color: const Color(0xFF1E6B5C),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    name,
                    style: TextStyle(
                      fontFamily: AppConstants.uthmaniFont,
                      fontSize: isLarge ? 24 : 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0D3B2E),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            _headerMetaBox('رُکوعاتها', sNum == 1 ? '۱' : (sNum == 2 ? '۴۰' : '---')),
          ],
        ),
      ),
    );
  }

  Widget _headerMetaBox(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFFD4AF37), width: 0.8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: const TextStyle(fontSize: 7, fontWeight: FontWeight.bold, color: Color(0xFF1E6B5C))),
          Text(value, style: const TextStyle(fontFamily: AppConstants.uthmaniFont, fontSize: 9, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildOrnamentalBismillah(BuildContext context, {bool isActive = false, bool isLarge = false}) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 2, horizontal: isLarge ? 40 : 0),
      height: isLarge ? 45 : 36,
      decoration: BoxDecoration(
        color: isActive ? const Color(0x22D4AF37) : const Color(0xFFFCFAF5),
        border: const Border.symmetric(horizontal: BorderSide(color: Color(0xFFD4AF37), width: 1.0)),
      ),
      child: const Center(
        child: Text(
          'بِسْمِ اللهِ الرَّحْمٰنِ الرَّحِيمِ',
          style: TextStyle(
            fontFamily: AppConstants.uthmaniFont,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0D3B2E),
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
