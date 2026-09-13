import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/constants/constants.dart';
import 'juz_detail_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class JuzListScreen extends StatelessWidget {
  const JuzListScreen({super.key});

  /// Canonical 549-Page Pakistani 16-Line Mushaf Juz Mapping
  static const List<Map<String, String>> juzData = [
    {'en': 'Alif Lam Meem', 'ar': 'الٓمّٓ', 'page': '2'},
    {'en': 'Sayaqool', 'ar': 'سَيَقُوْلُ', 'page': '19'},
    {'en': 'Tilkal Rusull', 'ar': 'تِلْكَ الرُّسُلُ', 'page': '37'},
    {'en': 'Lan Tana Loo', 'ar': 'لَنْ تَنَالُوْا', 'page': '55'},
    {'en': 'Wal Mohsanat', 'ar': 'وَالْمُحْصَنٰتُ', 'page': '73'},
    {'en': 'La Yuhibbullah', 'ar': 'لَا يُحِبُّ اللّٰهُ', 'page': '91'},
    {'en': 'Wa Iza Samiu', 'ar': 'وَإِذَا سَمِعُوْا', 'page': '109'},
    {'en': 'Wa Lau Annana', 'ar': 'وَلَوْ أَنَّنَا', 'page': '127'},
    {'en': 'Qal Al-Mala', 'ar': 'قَالَ الْمَلَاُ', 'page': '145'},
    {'en': 'Wa\'lamu', 'ar': 'وَاعْلَمُوْا', 'page': '163'},
    {'en': 'Ya\'tazirun', 'ar': 'يَعْتَذِرُوْنَ', 'page': '181'},
    {'en': 'Wa Ma Min Dabbah', 'ar': 'وَمَا مِنْ دَابَّةٍ', 'page': '199'},
    {'en': 'Wa Ma Ubarriu', 'ar': 'وَمَا أُبَرِّئُ', 'page': '217'},
    {'en': 'Rubama', 'ar': 'رُبَمَا', 'page': '235'},
    {'en': 'Subhanallazi', 'ar': 'سُبْحٰنَ الَّذِيْ', 'page': '253'},
    {'en': 'Qal Alam', 'ar': 'قَالَ أَلَمْ', 'page': '271'},
    {'en': 'Aqtaraba', 'ar': 'اقْتَرَبَ', 'page': '289'},
    {'en': 'Qad Aflaha', 'ar': 'قَدْ أَفْلَحَ', 'page': '307'},
    {'en': 'Wa Qallazina', 'ar': 'وَقَالَ الَّذِيْنَ', 'page': '325'},
    {'en': 'Aman Khalaq', 'ar': 'أَمَّنْ خَلَقَ', 'page': '343'},
    {'en': 'Utlu Ma Uhiya', 'ar': 'اتْلُ مَا أُوْحِيَ', 'page': '361'},
    {'en': 'Wa Man Yaqnut', 'ar': 'وَمَنْ يَّقْنُتْ', 'page': '379'},
    {'en': 'Wa Maliya', 'ar': 'وَمَا لِيَ', 'page': '397'},
    {'en': 'Faman Azlam', 'ar': 'فَمَنْ أَظْلَمُ', 'page': '415'},
    {'en': 'Ilayhi Yuraddu', 'ar': 'إِلَيْهِ يُرَدُّ', 'page': '433'},
    {'en': 'Ha Meem', 'ar': 'حٰمٓ', 'page': '451'},
    {'en': 'Qala Fama Khatbukum', 'ar': 'قَالَ فَمَا خَطْبُكُمْ', 'page': '469'},
    {'en': 'Qad Sami Allah', 'ar': 'قَدْ سَمِعَ اللّٰهُ', 'page': '487'},
    {'en': 'Tabarakallazi', 'ar': 'تَبٰرَكَ الَّذِيْ', 'page': '505'},
    {'en': 'Amma Yatasa\'alun', 'ar': 'عَمَّ يَتَسَاءَلُوْنَ', 'page': '523'},
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        physics: const BouncingScrollPhysics(),
        itemCount: juzData.length,
        itemBuilder: (context, index) {
          final juz = juzData[index];
          final juzNumber = index + 1;
          return _buildJuzCard(context, juz, juzNumber, isDark);
        },
      ),
    );
  }

  Widget _buildJuzCard(BuildContext context, Map<String, String> juz, int number, bool isDark) {
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
                      builder: (context) => JuzDetailScreen(juzNumber: number),
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
                                '$number',
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
                                    'Para $number',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: AppConstants.accentGreen,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    'Starts at Page ${juz['page']}',
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
  }
}
