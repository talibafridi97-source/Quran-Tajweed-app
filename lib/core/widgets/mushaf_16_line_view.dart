import 'package:flutter/material.dart';
import '../../models/mushaf_16_line_model.dart';
import '../../core/constants/constants.dart';
import '../../core/utils/tajweed_parser.dart';
import '../../services/audio_manager_service.dart';
import 'package:google_fonts/google_fonts.dart';

/// Luxury Indo-Pak 16-Line Mushaf Page View.
/// Features high-fidelity medallions for Ayah markers and premium Para highlighting.
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

  void _showLuxuryLafziTarjuma(BuildContext context, MushafLineSegment segment) {
    if (segment.translation == null || segment.translation!.isEmpty) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        margin: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 30, offset: const Offset(0, -5))],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 50, height: 5, 
                decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(10)),
              ),
              const SizedBox(height: 32),
              // Word Section
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F2E6),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppConstants.gold.withValues(alpha: 0.2)),
                ),
                child: Text(
                  segment.text,
                  style: TextStyle(
                    fontFamily: fontFamily,
                    fontSize: 48,
                    fontWeight: FontWeight.w900,
                    color: AppConstants.primaryGreen,
                    height: 1.1,
                  ),
                  textDirection: TextDirection.rtl,
                ),
              ),
              const SizedBox(height: 24),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.auto_awesome, color: AppConstants.gold, size: 18),
                  SizedBox(width: 10),
                  Text(
                    'LAFZI TARJUMA (Urdu)',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: AppConstants.gold, letterSpacing: 1.2),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Translation Content
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF0D3B2E),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [BoxShadow(color: AppConstants.primaryGreen.withValues(alpha: 0.2), blurRadius: 10)],
                ),
                child: Text(
                  segment.translation!,
                  style: GoogleFonts.notoNastaliqUrdu(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.9,
                  ),
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl,
                ),
              ),
              const SizedBox(height: 24),
              // Close Action
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.grey[50],
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('SubhanAllah', style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
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
          clipBehavior: Clip.none,
          children: [
            Column(
              children: List.generate(16, (index) {
                final line = index < page.lines.length ? page.lines[index] : null;
                final bool isStart = line?.isParaStart ?? false;

                return Expanded(
                  flex: (line?.isSurahHeader == true && isSpecialHeaderPage) ? 3 : 1,
                  child: Stack(
                    alignment: Alignment.center,
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: double.infinity,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          // Luxury Gold foil effect for Para start
                          gradient: isStart ? LinearGradient(
                            colors: [const Color(0xFFFFD700).withValues(alpha: 0.3), const Color(0xFFFFD700).withValues(alpha: 0.1), const Color(0xFFFFD700).withValues(alpha: 0.3)],
                          ) : null,
                          border: Border(bottom: BorderSide(color: isStart ? const Color(0xFFFFD700) : const Color(0x0A000000), width: isStart ? 1.5 : 0.4)),
                        ),
                        child: line != null 
                            ? _buildLineSlot(context, line, activeVerseKey, isSpecialHeaderPage)
                            : const SizedBox.shrink(),
                      ),
                      
                      if (line != null && line.isRukuEnd)
                        Positioned(
                          right: -12, 
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('ع', style: TextStyle(fontFamily: AppConstants.uthmaniFont, fontSize: 13, fontWeight: FontWeight.w900, color: Color(0xFF1E6B5C))),
        Text(TajweedParser.toArabicDigits(rukuNum), style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: Color(0xFF1E6B5C))),
      ],
    );
  }

  Widget _buildLineSlot(BuildContext context, Mushaf16Line line, String? activeKey, bool isSpecial) {
    if (line.isSurahHeader) return _buildLuxuryHeader(context, line.surahName, line.surahNumber, isLarge: isSpecial);
    if (line.isBismillah) return _buildLuxuryBismillah(context, isActive: activeKey == '${line.surahNumber}:0');
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
          width: 580, 
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween, 
            textDirection: TextDirection.rtl,
            children: line.segments.map((seg) {
              final active = activeKey != null && seg.verseKey == activeKey;

              Widget w;
              if (seg.isAyahEnd) {
                w = Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppConstants.gold, width: 1.5),
                  ),
                  child: Text(
                    seg.text.replaceAll('﴾', '').replaceAll('﴿', '').trim(), 
                    style: TextStyle(
                      color: AppConstants.gold, 
                      fontSize: fontSize * 0.5, 
                      fontWeight: FontWeight.w900, 
                      backgroundColor: active ? const Color(0x44D4AF37) : null
                    )
                  ),
                );
              } else {
                final spans = TajweedParser.parse(seg.text, fontSize: fontSize, fontFamily: fontFamily, defaultColor: textColor, showTajweed: showTajweed);
                final styled = spans.map((s) => (s is TextSpan) ? TextSpan(text: s.text, style: s.style?.copyWith(fontWeight: weight, height: 1.0, leadingDistribution: TextLeadingDistribution.even, backgroundColor: active ? const Color(0x44D4AF37) : null)) : s).toList();
                w = Text.rich(TextSpan(children: styled), textDirection: TextDirection.rtl, textAlign: TextAlign.center, maxLines: 1, strutStyle: const StrutStyle(forceStrutHeight: true, height: 1.0, leading: 0));
              }

              return GestureDetector(
                onTap: () {
                  _showLuxuryLafziTarjuma(context, seg);
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

  Widget _buildLuxuryHeader(BuildContext context, String name, int sNum, {bool isLarge = false}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Colors.white, Color(0xFFF7F2E6)]),
        borderRadius: BorderRadius.circular(8), 
        border: Border.all(color: const Color(0xFF1E6B5C), width: isLarge ? 2.5 : 1.2), 
        boxShadow: [BoxShadow(color: const Color(0xFFD4AF37).withValues(alpha: 0.1), blurRadius: 4, offset: const Offset(0, 2))]
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween, 
          children: [
            _metaBox('آياتُها', sNum == 1 ? '۷' : (sNum == 2 ? '۲۸۶' : '---')),
            Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text('سُورَةُ', style: TextStyle(fontFamily: fontFamily, fontSize: 10, color: const Color(0xFF1E6B5C), fontWeight: FontWeight.bold)),
              Text(name, style: TextStyle(fontFamily: fontFamily, fontSize: 24, fontWeight: FontWeight.w900, color: const Color(0xFF0D3B2E))),
            ])),
            _metaBox('رُكوعاتها', sNum == 1 ? '۱' : (sNum == 2 ? '۴۰' : '---')),
          ]
        ),
      ),
    );
  }

  Widget _metaBox(String l, String v) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), 
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4), border: Border.all(color: const Color(0xFFD4AF37), width: 0.8)), 
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Text(l, style: const TextStyle(fontSize: 6, fontWeight: FontWeight.bold, color: Color(0xFF1E6B5C))),
      Text(v, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900)),
    ])
  );

  Widget _buildLuxuryBismillah(BuildContext context, {bool isActive = false}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 24), 
      decoration: BoxDecoration(
        color: isActive ? const Color(0x22D4AF37) : Colors.white, 
        border: const Border.symmetric(horizontal: BorderSide(color: Color(0xFFD4AF37), width: 1.0))
      ), 
      child: Center(child: FittedBox(fit: BoxFit.scaleDown, child: Text('بِسْمِ اللهِ الرَّحْمٰنِ الرَّحِيمِ', style: TextStyle(fontFamily: AppConstants.uthmaniFont, fontSize: 24, fontWeight: FontWeight.w900, color: const Color(0xFF0D3B2E))))),
    );
  }
}
