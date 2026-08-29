import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/surah.dart';
import '../constants/constants.dart';

/// Modern Luxury Glassmorphic Surah Card Tile
/// Responsive & safe text rendering with dynamic font scaling and flexible layouts.
class SurahCardTile extends StatelessWidget {
  final Surah surah;
  final VoidCallback? onTap;
  final VoidCallback? onPlayTap;
  final bool isPlaying;
  final bool isRead;

  const SurahCardTile({
    super.key,
    required this.surah,
    this.onTap,
    this.onPlayTap,
    this.isPlaying = false,
    this.isRead = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isMeccan = surah.revelationType.toLowerCase().contains('mecca') ||
        surah.revelationType.toLowerCase().contains('makki');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.35)
                : AppConstants.primaryGreen.withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            decoration: BoxDecoration(
              color: isDark
                  ? AppConstants.surfaceDark.withValues(alpha: 0.85)
                  : Colors.white.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: isPlaying
                    ? AppConstants.gold
                    : isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : AppConstants.primaryGreen.withValues(alpha: 0.08),
                width: isPlaying ? 1.5 : 1.0,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(22),
                splashColor: AppConstants.primaryGreen.withValues(alpha: 0.1),
                highlightColor: AppConstants.gold.withValues(alpha: 0.05),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Row(
                    children: [
                      // 1. Surah Number Medallion Badge
                      _buildSurahNumberBadge(isDark),

                      const SizedBox(width: 12),

                      // 2. Transliterated Name & Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    surah.englishName,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: isDark
                                          ? AppConstants.textPrimaryDark
                                          : AppConstants.textPrimaryLight,
                                      letterSpacing: -0.2,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (isPlaying) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppConstants.gold.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Text(
                                      'PLAYING',
                                      style: TextStyle(
                                        color: AppConstants.gold,
                                        fontSize: 8.5,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 3),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Revelation type badge
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: (isMeccan ? AppConstants.gold : AppConstants.accentGreen)
                                        .withValues(alpha: isDark ? 0.2 : 0.12),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: (isMeccan ? AppConstants.gold : AppConstants.accentGreen)
                                          .withValues(alpha: 0.3),
                                      width: 0.7,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        isMeccan ? Icons.location_on_rounded : Icons.mosque_rounded,
                                        size: 10,
                                        color: isMeccan ? AppConstants.goldMatte : AppConstants.accentGreen,
                                      ),
                                      const SizedBox(width: 3),
                                      Text(
                                        isMeccan ? 'Meccan' : 'Medinan',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          color: isMeccan ? AppConstants.goldMatte : AppConstants.accentGreen,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    '${surah.numberOfAyahs} Verses',
                                    style: GoogleFonts.plusJakartaSans(
                                      color: isDark
                                          ? AppConstants.textSecondaryDark
                                          : AppConstants.textSecondaryLight,
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 8),

                      // 3. Authentic Arabic Name Calligraphy (Scales safely down)
                      Flexible(
                        flex: 0,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 110),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerRight,
                            child: Text(
                              surah.name,
                              style: TextStyle(
                                fontFamily: AppConstants.uthmaniFont,
                                fontSize: 21,
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? AppConstants.goldLight
                                    : AppConstants.primaryGreen,
                              ),
                              maxLines: 1,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSurahNumberBadge(bool isDark) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isPlaying
              ? [AppConstants.goldLight, AppConstants.gold]
              : isDark
                  ? [
                      AppConstants.deepEmerald.withValues(alpha: 0.9),
                      AppConstants.primaryGreen.withValues(alpha: 0.5),
                    ]
                  : [
                      AppConstants.primaryGreen.withValues(alpha: 0.12),
                      AppConstants.primaryGreen.withValues(alpha: 0.05),
                    ],
        ),
        border: Border.all(
          color: isPlaying
              ? AppConstants.gold
              : isDark
                  ? AppConstants.gold.withValues(alpha: 0.3)
                  : AppConstants.primaryGreen.withValues(alpha: 0.2),
          width: 1.2,
        ),
      ),
      child: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Text(
              '${surah.number}',
              style: GoogleFonts.plusJakartaSans(
                color: isPlaying
                    ? Colors.black87
                    : isDark
                        ? AppConstants.gold
                        : AppConstants.primaryGreen,
                fontWeight: FontWeight.w800,
                fontSize: 14.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
