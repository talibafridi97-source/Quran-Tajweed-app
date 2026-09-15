import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/constants.dart';
import '../../services/mushaf_16_line_layout_service.dart';
import 'juz_detail_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class JuzListScreen extends StatelessWidget {
  const JuzListScreen({super.key});

  static const List<Map<String, String>> juzNames = [
    {'en': 'Alif Lam Meem', 'ar': 'الٓمّٓ'},
    {'en': 'Sayaqool', 'ar': 'سَيَقُوْلُ'},
    {'en': 'Tilkal Rusull', 'ar': 'تِلْكَ الرُّسُلُ'},
    {'en': 'Lan Tana Loo', 'ar': 'لَنْ تَنَالُوْا'},
    {'en': 'Wal Mohsanat', 'ar': 'وَالْمُحْصَنٰتُ'},
    {'en': 'La Yuhibbullah', 'ar': 'لَا يُحِبُّ اللّٰهُ'},
    {'en': 'Wa Iza Samiu', 'ar': 'وَإِذَا سَمِعُوْا'},
    {'en': 'Wa Lau Annana', 'ar': 'وَلَوْ أَنَّنَا'},
    {'en': 'Qal Al-Mala', 'ar': 'قَالَ الْمَلَاُ'},
    {'en': 'Wa\'lamu', 'ar': 'وَاعْلَمُوْا'},
    {'en': 'Ya\'tazirun', 'ar': 'يَعْتَذِرُوْنَ'},
    {'en': 'Wa Ma Min Dabbah', 'ar': 'وَمَا مِنْ دَابَّةٍ'},
    {'en': 'Wa Ma Ubarriu', 'ar': 'وَمَا أُبَرِّئُ'},
    {'en': 'Rubama', 'ar': 'رُبَمَا'},
    {'en': 'Subhanallazi', 'ar': 'سُبْحٰنَ الَّذِيْ'},
    {'en': 'Qal Alam', 'ar': 'قَالَ أَلَمْ'},
    {'en': 'Aqtaraba', 'ar': 'اقْتَرَبَ'},
    {'en': 'Qad Aflaha', 'ar': 'قَدْ أَفْلَحَ'},
    {'en': 'Wa Qallazina', 'ar': 'وَقَالَ الَّذِيْنَ'},
    {'en': 'Aman Khalaq', 'ar': 'أَمَّنْ خَلَقَ'},
    {'en': 'Utlu Ma Uhiya', 'ar': 'اتْلُ مَا أُوْحِيَ'},
    {'en': 'Wa Man Yaqnut', 'ar': 'وَمَنْ يَّقْنُتْ'},
    {'en': 'Wa Maliya', 'ar': 'وَمَا لِيَ'},
    {'en': 'Faman Azlam', 'ar': 'فَمَنْ أَظْلَمُ'},
    {'en': 'Ilayhi Yuraddu', 'ar': 'إِلَيْهِ يُرَدُّ'},
    {'en': 'Ha Meem', 'ar': 'حٰمٓ'},
    {'en': 'Qala Fama Khatbukum', 'ar': 'قَالَ فَمَا خَطْبُكُمْ'},
    {'en': 'Qad Sami Allah', 'ar': 'قَدْ سَمِعَ اللّٰهُ'},
    {'en': 'Tabarakallazi', 'ar': 'تَبٰرَكَ الَّذِيْ'},
    {'en': 'Amma Yatasa\'alun', 'ar': 'عَمَّ يَتَسَاءَلُوْنَ'},
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final layoutService = Mushaf16LineLayoutService.instance;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        physics: const BouncingScrollPhysics(),
        itemCount: juzNames.length,
        itemBuilder: (context, index) {
          final juz = juzNames[index];
          final juzNumber = index + 1;
          final startPage = layoutService.isReady ? layoutService.getJuzStartPage(juzNumber) : 0;

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
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.08)
                          : AppConstants.primaryGreen.withValues(alpha: 0.08),
                      width: 1.0,
                    ),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => JuzDetailScreen(juzNumber: juzNumber),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(22),
                      splashColor: AppConstants.primaryGreen.withValues(alpha: 0.1),
                      highlightColor: AppConstants.gold.withValues(alpha: 0.05),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        child: Row(
                          children: [
                            // Medallion
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: isDark
                                      ? [
                                          AppConstants.deepEmerald.withValues(alpha: 0.9),
                                          AppConstants.primaryGreen.withValues(alpha: 0.5),
                                        ]
                                      : [
                                          AppConstants.gold.withValues(alpha: 0.18),
                                          AppConstants.gold.withValues(alpha: 0.08),
                                        ],
                                ),
                                border: Border.all(
                                  color: isDark
                                      ? AppConstants.gold.withValues(alpha: 0.3)
                                      : AppConstants.gold.withValues(alpha: 0.4),
                                  width: 1.2,
                                ),
                              ),
                              child: Center(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: Text(
                                      '$juzNumber',
                                      style: GoogleFonts.plusJakartaSans(
                                        color: isDark ? AppConstants.gold : AppConstants.goldMatte,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 14.5,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    juz['en']!,
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
                                  const SizedBox(height: 3),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppConstants.accentGreen.withValues(alpha: isDark ? 0.2 : 0.12),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          'Para $juzNumber',
                                          style: const TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700,
                                            color: AppConstants.accentGreen,
                                          ),
                                        ),
                                      ),
                                      if (startPage > 0) ...[
                                        const SizedBox(width: 6),
                                        Flexible(
                                          child: Text(
                                            'Starts at Page $startPage',
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
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              flex: 0,
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 110),
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    juz['ar']!,
                                    style: TextStyle(
                                      fontFamily: AppConstants.uthmaniFont,
                                      fontSize: 21,
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? AppConstants.goldLight : AppConstants.primaryGreen,
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
        },
      ),
    );
  }
}
