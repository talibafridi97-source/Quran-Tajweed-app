import 'package:flutter/material.dart';
import '../../models/mushaf_16_line_model.dart';
import '../../core/constants/constants.dart';
import '../../core/utils/tajweed_parser.dart';
import '../../services/audio_manager_service.dart';
import 'package:google_fonts/google_fonts.dart';

/// Professional Indo-Pak 16-Line Mushaf Page View.
/// Features:
/// - Lafzi Tarjuma (Word-by-Word Translation) on Tap.
/// - Ruku (ع) markers in the margins.
/// - Vibrant Tajweed coloring and Ultra-Bold script.
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

  void _showLafziTarjuma(BuildContext context, MushafLineSegment segment) {
    if (segment.translation == null || segment.translation!.isEmpty) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4, 
              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 20),
            Text(
              segment.text,
              style: TextStyle(
                fontFamily: fontFamily,
                fontSize: 36,
                fontWeight: FontWeight.w900,
                color: AppConstants.primaryGreen,
              ),
              textDirection: TextDirection.rtl,
            ),
            const SizedBox(height: 12),
            const Text(
              'Lafzi Tarjuma (لفظی ترجمہ)',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppConstants.gold),
            ),
            const SizedBox(height: 16),
            Text(
              segment.translation!,
              style: GoogleFonts.notoNastaliqUrdu(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF14171A),
                height: 1.8,
              ),
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

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

        return Stack(
          children: [
            Column(
              children: List.generate(16, (index) {
                final line = index < page.lines.length ? page.lines[index] : null;
                final bool isStart = line?.isParaStart ?? false;

                return Expanded(
                  flex: (line?.isSurahHeader == true && isSpecialHeaderPage) ? 3 : 1,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: double.infinity,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isStart ? const Color(0xFFFFD700) : null,
                          border: Border(bottom: BorderSide(color: isStart ? const Color(0xFFFFD700) : const Color(0x0A000000), width: isStart ? 1.0 : 0.4)),
                        ),
                        child: line != null 
                            ? _buildLineSlot(context, line, activeVerseKey, isSpecialHeaderPage)
                            : const SizedBox.shrink(),
                      ),
                      
                      // Ruku Marker (ع) on the left margin
                      if (line != null && line.isRukuEnd)
                        Positioned(
                          left: 2,
                          child: _buildRukuMarker(line.rukuNumber ?? 0),
                        ),
                    ],
                  ),
                );
              }),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRukuMarker(int rukuNum) {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppConstants.primaryGreen, width: 0.5),
      ),
      child: const Text(
        'ع',
        style: TextStyle(
          fontFamily: AppConstants.uthmaniFont,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: AppConstants.primaryGreen,
        ),
      ),
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
    final Color textColor = isStart ? const Color(0xFFD32F2F) : const Color(0xFF14171A);
    final FontWeight weight = isStart ? FontWeight.w900 : FontWeight.w800;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: FittedBox(
        fit: BoxFit.contain,
        alignment: Alignment.center,
        child: SizedBox(
          width: 600, 
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
                    color: isStart ? const Color(0xFFD32F2F) : AppConstants.gold, 
                    fontSize: fontSize * 0.9, 
                    fontWeight: FontWeight.bold, 
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
                        fontWeight: weight,
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
                  strutStyle: const StrutStyle(forceStrutHeight: true, height: 1.0, leading: 0),
                );
              }

              return GestureDetector(
                onTap: () {
                  _showLafziTarjuma(context, seg);
                  audioManager.playAyah(surahNumber: seg.surahNumber, ayahNumber: seg.ayahNumberInSurah, surahName: line.surahName);
                },
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
      margin: EdgeInsets.symmetric(vertical: 2, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(4), 
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
                Text('سُورَةُ', style: TextStyle(fontFamily: fontFamily, fontSize: 10, color: const Color(0xFF1E6B5C), fontWeight: FontWeight.bold)),
                Text(name, style: TextStyle(fontFamily: fontFamily, fontSize: 24, fontWeight: FontWeight.w900, color: const Color(0xFF0D3B2E))),
              ]
            )
          ),
          _metaBox('رُكوعاتها', sNum == 1 ? '۱' : (sNum == 2 ? '۴۰' : '---')),
        ]
      ),
    );
  }

  Widget _metaBox(String l, String v) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1), 
    decoration: BoxDecoration(color: const Color(0xFFF7F2E6), borderRadius: BorderRadius.circular(2), border: Border.all(color: const Color(0xFFD4AF37), width: 0.6)), 
    child: Column(
      mainAxisSize: MainAxisSize.min, 
      children: [
        Text(l, style: const TextStyle(fontSize: 6, fontWeight: FontWeight.bold, color: Color(0xFF1E6B5C))),
        Text(v, style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w900)),
      ]
    )
  );

  Widget _buildBismillah(BuildContext context, {bool isActive = false}) {
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
