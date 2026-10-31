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
    this.fontFamily = AppConstants.indoPakFont,
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
    if (line.isSurahHeader) return _buildLuxuryHeader(context, line, isLarge: isSpecial);
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
                  width: fontSize * 0.85,
                  height: fontSize * 0.85,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFFFF8E7),
                    border: Border.all(color: const Color(0xFF1E6B5C), width: 1.4),
                    boxShadow: const [BoxShadow(color: Color(0x33000000), blurRadius: 1)],
                  ),
                  child: Text(
                    seg.text.replaceAll('﴾', '').replaceAll('﴿', '').trim(), 
                    style: TextStyle(
                      color: const Color(0xFF0D3B2E), 
                      fontSize: fontSize * 0.38, 
                      fontWeight: FontWeight.w900, 
                      backgroundColor: active ? const Color(0x44D4AF37) : null,
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

  Widget _buildLuxuryHeader(BuildContext context, Mushaf16Line line, {bool isLarge = false}) {
    final ayahs = line.ayahCount != null ? TajweedParser.toArabicDigits(line.ayahCount!) : '—';
    final rukus = line.rukuCount != null ? TajweedParser.toArabicDigits(line.rukuCount!) : '—';
    final revelation = (line.revelationType ?? '').toLowerCase().startsWith('med') ? 'مَدَنِيَّةٌ' : 'مَكِّيَّةٌ';

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFFDF6), Color(0xFFF3E6C5), Color(0xFFFFFDF6)],
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF1E6B5C), width: isLarge ? 2.4 : 1.4),
        boxShadow: [BoxShadow(color: const Color(0xFFD4AF37).withValues(alpha: 0.18), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _metaBox('آيَاتُهَا', ayahs),
            Expanded(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(line.surahName, style: TextStyle(fontFamily: fontFamily, fontSize: 22, fontWeight: FontWeight.w900, color: const Color(0xFF0D3B2E))),
                    Text(revelation, style: TextStyle(fontFamily: fontFamily, fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFF1E6B5C))),
                  ],
                ),
              ),
            ),
            _metaBox('رُكُوعَاتُهَا', rukus),
          ],
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
    const tagged = 'بِسْمِ [h:1[ٱ]للَّهِ [h:2[ٱ][l[ل]رَّحْمَ[n[ـٰ]نِ [h:3[ٱ][l[ل]رَّح[p[ِي]مِ';
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isActive
              ? const [Color(0xFFFFE082), Color(0xFFFFF8E1), Color(0xFFFFE082)]
              : const [Color(0xFFF8EFC8), Color(0xFFFFF8E7), Color(0xFFF8EFC8)],
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFC5A059), width: 1.0),
      ),
      child: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text.rich(
            TextSpan(
              children: TajweedParser.parse(
                tagged,
                fontSize: 22,
                fontFamily: fontFamily,
                defaultColor: const Color(0xFF0D3B2E),
                showTajweed: showTajweed,
              ),
            ),
            textDirection: TextDirection.rtl,
          ),
        ),
      ),
    );
  }
}
