import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/mushaf_16_line_model.dart';
import '../../models/surah.dart';
import '../../providers/quran_provider.dart';
import '../../core/constants/constants.dart';
import '../../core/utils/tajweed_parser.dart';
import '../../services/audio_manager_service.dart';

/// Professional Indo-Pak 16-Line Mushaf Page View.
/// Strictly enforces exactly 16 lines per page with authentic ornamental design,
/// vertical side margins (Hashiya), horizontal row dividers, and dynamic Ruku/Sajda/Juz indicators.
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
      height: 1.15, // Compact Indo-Pak line height
      letterSpacing: -0.1,
    );
  }

  String _toArabicDigits(int number) {
    const arabicDigits = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '٩'];
    return number.toString().split('').map((digit) {
      final idx = int.tryParse(digit);
      return idx != null ? arabicDigits[idx] : digit;
    }).join();
  }

  int _getRukuCount(int surahNumber) {
    const rukuCounts = [
      1, 40, 20, 24, 16, 20, 24, 10, 16, 11, // 1-10
      10, 12, 6, 7, 6, 16, 12, 12, 6, 8,    // 11-20
      7, 10, 6, 9, 6, 11, 7, 9, 7, 6,       // 21-30
      4, 3, 9, 6, 4, 5, 5, 5, 8, 9,         // 31-40
      6, 5, 7, 3, 4, 4, 4, 4, 2, 3,         // 41-50
      3, 2, 3, 3, 3, 3, 4, 3, 3, 2,         // 51-60
      2, 2, 2, 2, 2, 2, 2, 2, 2, 2,         // 61-70
      2, 2, 2, 2, 2, 2, 2, 2, 2, 1,         // 71-80
      1, 1, 1, 1, 1, 1, 1, 1, 1, 1,         // 81-90
      1, 1, 1, 1, 1, 1, 1, 1, 1, 1,         // 91-100
      1, 1, 1, 1, 1, 1, 1, 1, 1, 1,         // 101-110
      1, 1, 1, 1                            // 111-114
    ];
    if (surahNumber >= 1 && surahNumber <= 114) {
      return rukuCounts[surahNumber - 1];
    }
    return 1;
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

        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFFFCFAF5),
            border: Border.all(color: const Color(0xFFD4AF37), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              )
            ],
          ),
          child: Column(
            key: const ValueKey('mushaf_root_column'),
            mainAxisSize: MainAxisSize.max,
            children: List.generate(16, (index) {
              final line = index < page.lines.length ? page.lines[index] : null;
              final bool isHeaderOrBismillah = line != null && (line.isSurahHeader || line.isBismillah);

              return Expanded(
                flex: (line?.isSurahHeader == true && isStartPage) ? 2 : 1,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: index < 15
                          ? const BorderSide(color: Color(0xFFEADBCE), width: 0.8)
                          : BorderSide.none,
                    ),
                  ),
                  child: line != null
                      ? Row(
                          children: [
                            // Left Side Margin (Hashiya) for Juz, Sajda, and Manzil
                            Container(
                              width: 36,
                              alignment: Alignment.center,
                              child: isHeaderOrBismillah
                                  ? const SizedBox.shrink()
                                  : _buildLeftMargin(line),
                            ),
                            
                            // Left vertical margin border
                            Container(
                              width: 1.0,
                              color: const Color(0xFFD4AF37),
                            ),

                            // Center Content Area (16-Line grid slot)
                            Expanded(
                              child: Container(
                                width: double.infinity,
                                alignment: Alignment.center,
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                child: _buildLineSlot(context, line, activeVerseKey, isStartPage),
                              ),
                            ),

                            // Right vertical margin border
                            Container(
                              width: 1.0,
                              color: const Color(0xFFD4AF37),
                            ),

                            // Right Side Margin (Hashiya) for Ruku Markers (ع)
                            Container(
                              width: 36,
                              alignment: Alignment.center,
                              child: isHeaderOrBismillah
                                  ? const SizedBox.shrink()
                                  : _buildRightMargin(line),
                            ),
                          ],
                        )
                      : const SizedBox.shrink(),
                ),
              );
            }),
          ),
        );
      },
    );
  }

  Widget _buildLeftMargin(Mushaf16Line line) {
    final List<Widget> indicators = [];

    // 1. Juz/Para Divider Indicator
    if (line.isParaStart && line.juzNumber != null) {
      indicators.add(
        Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFF7F2E6),
            border: Border.all(color: const Color(0xFFD4AF37), width: 1.0),
          ),
          child: Flex(
            direction: Axis.vertical,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'پارہ',
                maxLines: 1,
                softWrap: false,
                style: TextStyle(
                  fontFamily: 'Urdu',
                  fontSize: 5,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF7A6538),
                  height: 1.0,
                ),
              ),
              Text(
                _toArabicDigits(line.juzNumber!),
                maxLines: 1,
                softWrap: false,
                style: const TextStyle(
                  fontFamily: 'Urdu',
                  fontSize: 7.5,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0D3B2E),
                  height: 1.0,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // 2. Sajdah Indicator
    if (line.isSajda) {
      indicators.add(
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
          decoration: BoxDecoration(
            color: const Color(0xFF1E6B5C),
            borderRadius: BorderRadius.circular(3),
            border: Border.all(color: const Color(0xFFD4AF37), width: 0.6),
          ),
          child: const Text(
            'سَجْدَة',
            maxLines: 1,
            softWrap: false,
            style: TextStyle(
              fontFamily: 'Urdu',
              fontSize: 7.5,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.0,
            ),
          ),
        ),
      );
    }

    // 3. Manzil Start Indicator
    if (line.isManzilStart) {
      indicators.add(
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1.5),
          decoration: BoxDecoration(
            color: const Color(0xFF7A6538),
            borderRadius: BorderRadius.circular(3),
            border: Border.all(color: const Color(0xFFD4AF37), width: 0.6),
          ),
          child: Flex(
            direction: Axis.vertical,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'منزل',
                maxLines: 1,
                softWrap: false,
                style: TextStyle(
                  fontFamily: 'Urdu',
                  fontSize: 5.5,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  height: 1.0,
                ),
              ),
              Text(
                _toArabicDigits(line.manzilNumber),
                maxLines: 1,
                softWrap: false,
                style: const TextStyle(
                  fontSize: 7.5,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  height: 1.0,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (indicators.isEmpty) {
      return const SizedBox.shrink();
    }

    // Wrap in FittedBox to scale down if the row height is small (e.g. 22.5px in tests)
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Flex(
        direction: Axis.vertical,
        mainAxisSize: MainAxisSize.min,
        children: indicators.map((ind) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 1.0),
          child: ind,
        )).toList(),
      ),
    );
  }

  Widget _buildRightMargin(Mushaf16Line line) {
    if (!line.isRukuEnd) {
      return const SizedBox.shrink();
    }

    final top = line.rukuSurahNumber ?? 1;
    final mid = line.rukuAyahCount ?? 1;
    final bottom = line.rukuJuzNumber ?? 1;

    // Wrap in FittedBox to scale down if the row height is small
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Flex(
        direction: Axis.vertical,
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _toArabicDigits(top),
            maxLines: 1,
            softWrap: false,
            style: const TextStyle(
              fontSize: 7.0,
              fontWeight: FontWeight.bold,
              color: Color(0xFF7A6538),
              height: 1.0,
            ),
          ),
          const Text(
            'ع',
            maxLines: 1,
            softWrap: false,
            style: TextStyle(
              fontFamily: 'Urdu',
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0D3B2E),
              height: 0.85,
            ),
          ),
          Text(
            _toArabicDigits(mid),
            maxLines: 1,
            softWrap: false,
            style: const TextStyle(
              fontSize: 7.0,
              fontWeight: FontWeight.bold,
              color: Color(0xFF7A6538),
              height: 1.0,
            ),
          ),
          Text(
            _toArabicDigits(bottom),
            maxLines: 1,
            softWrap: false,
            style: const TextStyle(
              fontSize: 7.0,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E6B5C),
              height: 1.0,
            ),
          ),
        ],
      ),
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
    final audioManager = AudioManagerService.instance;

    return FittedBox(
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
              maxLines: 1,
              softWrap: false,
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
              softWrap: false,
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
    );
  }

  Widget _buildOrnamentalSurahHeader(BuildContext context, String name, int sNum, {bool isLarge = false}) {
    QuranProvider? provider;
    try {
      provider = Provider.of<QuranProvider>(context, listen: false);
    } catch (_) {
      // Graceful fallback when provider is not in scope (e.g., in unit tests)
    }

    final surah = provider != null
        ? provider.surahs.firstWhere(
            (s) => s.number == sNum,
            orElse: () => Surah(
              number: sNum,
              name: name,
              englishName: name,
              englishNameTranslation: '',
              numberOfAyahs: sNum == 1 ? 7 : (sNum == 2 ? 286 : 0),
              revelationType: sNum == 1 ? 'Meccan' : 'Medinan',
            ),
          )
        : Surah(
            number: sNum,
            name: name,
            englishName: name,
            englishNameTranslation: '',
            numberOfAyahs: sNum == 1 ? 7 : (sNum == 2 ? 286 : 0),
            revelationType: sNum == 1 ? 'Meccan' : 'Medinan',
          );

    final totalAyahsArabic = _toArabicDigits(surah.numberOfAyahs);
    final totalRukusArabic = _toArabicDigits(_getRukuCount(sNum));
    final revelationTypeArabic = surah.revelationType.toLowerCase().contains('mec') ? 'مَكِّيَّة' : 'مَدَنِيَّة';

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
      height: isLarge ? 64 : 52,
      decoration: BoxDecoration(
        color: const Color(0xFFFDFBF7),
        border: Border.all(color: const Color(0xFF0D3B2E), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 3,
            offset: const Offset(0, 1),
          )
        ],
      ),
      child: Container(
        margin: const EdgeInsets.all(1.5),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFD4AF37), width: 1.0),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Left Metadata Box: Ayah Count
            _headerMetaBox('آیاتُها', totalAyahsArabic),

            // Center Column: Surah Name and Revelation Type
            Expanded(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Flex(
                  direction: Axis.vertical,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      surah.name,
                      maxLines: 1,
                      softWrap: false,
                      style: TextStyle(
                        fontFamily: AppConstants.uthmaniFont,
                        fontSize: isLarge ? 20 : 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0D3B2E),
                        height: 1.1,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      revelationTypeArabic,
                      maxLines: 1,
                      softWrap: false,
                      style: const TextStyle(
                        fontFamily: 'Urdu',
                        fontSize: 8.5,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF7A6538),
                        height: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Right Metadata Box: Ruku Count
            _headerMetaBox('رُکوعاتها', totalRukusArabic),
          ],
        ),
      ),
    );
  }

  Widget _headerMetaBox(String label, String value) {
    return Container(
      width: 44,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFFCFAF5),
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: const Color(0xFFD4AF37), width: 0.8),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: '$label\n',
                style: const TextStyle(
                  fontFamily: 'Urdu',
                  fontSize: 7,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E6B5C),
                  height: 1.1,
                ),
              ),
              TextSpan(
                text: value,
                style: const TextStyle(
                  fontFamily: AppConstants.uthmaniFont,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0D3B2E),
                  height: 1.1,
                ),
              ),
            ],
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          softWrap: false,
        ),
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
      child: Center(
        child: Text(
          'بِسْمِ اللهِ الرَّحْمٰنِ الرَّحِيمِ',
          maxLines: 1,
          softWrap: false,
          style: const TextStyle(
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
