import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/routes/app_routes.dart';
import '../../core/constants/constants.dart';
import '../../providers/quran_provider.dart';
import '../../providers/khatam_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final quranProvider = context.watch<QuranProvider>();
    final khatamProvider = context.watch<KhatamProvider>();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        top: false,
        bottom: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildCompactHeader(context, colorScheme),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 110),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Last Read Hero Card (Quran First)
                    _buildLastReadHeroCard(context, quranProvider, colorScheme),

                    const SizedBox(height: 24),

                    // 2. Quran Navigation ("Explore Quran")
                    _buildSectionHeader(
                      context,
                      title: 'Explore Quran',
                      arabicTitle: 'تصفح القرآن',
                      icon: Icons.menu_book_rounded,
                    ),
                    const SizedBox(height: 12),
                    _buildQuranNavigationGrid(context, colorScheme),

                    const SizedBox(height: 24),

                    // 3. Daily Quran Progress
                    _buildProgressSection(context, quranProvider, khatamProvider, colorScheme),

                    const SizedBox(height: 24),

                    // 4. Islamic Utility Tools
                    _buildSectionHeader(
                      context,
                      title: 'Islamic Utilities',
                      arabicTitle: 'الأدوات الإسلامية',
                      icon: Icons.grid_view_rounded,
                    ),
                    const SizedBox(height: 12),
                    _buildIslamicUtilitiesGrid(context, colorScheme),

                    const SizedBox(height: 24),

                    // 5. Tajweed & Learning Quick Access
                    _buildSectionHeader(
                      context,
                      title: 'Learn & Explore',
                      arabicTitle: 'التعليم والتجويد',
                      icon: Icons.school_rounded,
                    ),
                    const SizedBox(height: 12),
                    _buildLearningGrid(context, colorScheme),

                    const SizedBox(height: 24),

                    // 6. Daily Inspiration Card
                    _buildDailyInspirationCard(context, colorScheme),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- 1. Compact Professional Header ---
  Widget _buildCompactHeader(BuildContext context, ColorScheme colorScheme) {
    return SliverAppBar(
      pinned: true,
      elevation: 0,
      scrolledUnderElevation: 0.5,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.95),
      toolbarHeight: 60,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: colorScheme.primary.withValues(alpha: 0.25)),
            ),
            child: Icon(Icons.auto_stories_rounded, size: 19, color: colorScheme.primary),
          ),
          const SizedBox(width: 9),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Tajweed Quran',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: colorScheme.onSurface,
                    letterSpacing: -0.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'القرآن الكريم والتجويد',
                  style: TextStyle(
                    fontFamily: AppConstants.uthmaniFont,
                    fontSize: 11.5,
                    color: colorScheme.primary,
                    height: 1.1,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        _buildHeaderActionButton(
          context,
          icon: Icons.search_rounded,
          tooltip: 'Search Quran',
          colorScheme: colorScheme,
          onTap: () => Navigator.pushNamed(context, AppRoutes.search),
        ),
        _buildHeaderActionButton(
          context,
          icon: Icons.bookmarks_rounded,
          tooltip: 'Saved & Notes',
          colorScheme: colorScheme,
          onTap: () => Navigator.pushNamed(context, AppRoutes.bookmarksNotes),
        ),
        _buildHeaderActionButton(
          context,
          icon: Icons.settings_outlined,
          tooltip: 'Settings',
          colorScheme: colorScheme,
          onTap: () => Navigator.pushNamed(context, AppRoutes.settings),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildHeaderActionButton(
    BuildContext context, {
    required IconData icon,
    required String tooltip,
    required ColorScheme colorScheme,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: IconButton(
        onPressed: onTap,
        tooltip: tooltip,
        iconSize: 19,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
        style: IconButton.styleFrom(
          backgroundColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          foregroundColor: colorScheme.onSurface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        icon: Icon(icon),
      ),
    );
  }

  // --- 2. Last Read Hero Card ---
  Widget _buildLastReadHeroCard(BuildContext context, QuranProvider provider, ColorScheme colorScheme) {
    final resume = provider.resumeData;
    final hasResume = resume != null;

    final surahTitle = hasResume ? resume.surahName : 'Surah Al-Fatihah';
    final subtitleText = hasResume
        ? 'Ayah ${resume.ayahNumber}  •  Juz ${resume.juz}  •  Page ${resume.page}'
        : 'Start reading from the beginning  •  Page 1';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary,
            Color.lerp(colorScheme.primary, Colors.black, 0.25) ?? colorScheme.primary,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.25),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Navigator.pushNamed(context, AppRoutes.quranPage),
          borderRadius: BorderRadius.circular(22),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            child: Stack(
              children: [
                Positioned(
                  right: -10,
                  bottom: -15,
                  child: Icon(
                    Icons.menu_book_rounded,
                    size: 110,
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.bookmark_added_rounded, size: 14, color: AppConstants.gold),
                              const SizedBox(width: 5),
                              Text(
                                hasResume ? 'Continue Reading' : 'Start Reading',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      surahTitle,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: -0.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitleText,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                hasResume ? 'Resume' : 'Open Mushaf',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.primary,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Icon(
                                Icons.arrow_forward_rounded,
                                size: 15,
                                color: colorScheme.primary,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- 3. Quran Navigation Grid (114 Surahs, 30 Paras, 604 Pages, Khatam Plan) ---
  Widget _buildQuranNavigationGrid(BuildContext context, ColorScheme colorScheme) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 2.15,
      children: [
        _buildQuranNavCard(
          context,
          colorScheme: colorScheme,
          badge: '114',
          title: 'Surahs',
          subtitle: 'Read by Surah',
          icon: Icons.format_list_numbered_rtl_rounded,
          route: AppRoutes.surahList,
        ),
        _buildQuranNavCard(
          context,
          colorScheme: colorScheme,
          badge: '30',
          title: 'Paras',
          subtitle: 'Read by Juz',
          icon: Icons.auto_stories_rounded,
          route: AppRoutes.juzList,
        ),
        _buildQuranNavCard(
          context,
          colorScheme: colorScheme,
          badge: '604',
          title: 'Pages',
          subtitle: 'Madani Mushaf',
          icon: Icons.chrome_reader_mode_rounded,
          route: AppRoutes.quranPage,
        ),
        _buildQuranNavCard(
          context,
          colorScheme: colorScheme,
          badge: 'Plan',
          title: 'Khatam',
          subtitle: 'Track Goals',
          icon: Icons.track_changes_rounded,
          route: AppRoutes.khatam,
        ),
      ],
    );
  }

  Widget _buildQuranNavCard(
    BuildContext context, {
    required ColorScheme colorScheme,
    required String badge,
    required String title,
    required String subtitle,
    required IconData icon,
    required String route,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Navigator.pushNamed(context, route),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 20, color: colorScheme.primary),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            badge,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: colorScheme.primary,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              title,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          color: colorScheme.onSurface.withValues(alpha: 0.55),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- 4. Quran Reading / Khatam Progress ---
  Widget _buildProgressSection(
    BuildContext context,
    QuranProvider quranProvider,
    KhatamProvider khatamProvider,
    ColorScheme colorScheme,
  ) {
    final resume = quranProvider.resumeData;
    final activePlan = khatamProvider.plans.isNotEmpty ? khatamProvider.plans.first : null;

    final int currentPage = resume?.page ?? 1;
    final double pageProgress = (currentPage / 604.0).clamp(0.0, 1.0);
    final int percentInt = (pageProgress * 100).round();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(Icons.auto_graph_rounded, size: 18, color: colorScheme.primary),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        activePlan != null ? 'Active Khatam: ${activePlan.title}' : 'Quran Reading Progress',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () => Navigator.pushNamed(context, AppRoutes.khatam),
                borderRadius: BorderRadius.circular(6),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  child: Text(
                    'Details',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: pageProgress,
              minHeight: 7,
              backgroundColor: colorScheme.primary.withValues(alpha: 0.12),
              valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Page $currentPage of 604 • Juz ${resume?.juz ?? 1} of 30',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$percentInt% Completed',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11.5,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- 5. Islamic Utility Tools Grid ---
  Widget _buildIslamicUtilitiesGrid(BuildContext context, ColorScheme colorScheme) {
    final List<Map<String, dynamic>> tools = [
      {'title': 'Prayer Times', 'icon': Icons.access_time_filled_rounded, 'route': AppRoutes.prayerTimes},
      {'title': 'Qibla Finder', 'icon': Icons.explore_rounded, 'route': AppRoutes.qibla},
      {'title': 'Tasbeeh', 'icon': Icons.fingerprint_rounded, 'route': AppRoutes.tasbeeh},
      {'title': 'Masnoon Duas', 'icon': Icons.menu_book_rounded, 'route': AppRoutes.duas},
      {'title': '99 Names', 'icon': Icons.stars_rounded, 'route': AppRoutes.allahNames},
      {'title': 'Hadith Books', 'icon': Icons.library_books_rounded, 'route': AppRoutes.hadithBooks},
      {'title': 'Daily Ayah', 'icon': Icons.lightbulb_rounded, 'route': AppRoutes.dailyAyah},
      {'title': 'Calendar', 'icon': Icons.calendar_month_rounded, 'route': AppRoutes.calendar},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 12,
        crossAxisSpacing: 10,
        childAspectRatio: 0.82,
      ),
      itemCount: tools.length,
      itemBuilder: (context, index) {
        final tool = tools[index];
        return _buildToolItem(
          context,
          title: tool['title'] as String,
          icon: tool['icon'] as IconData,
          route: tool['route'] as String,
          colorScheme: colorScheme,
        );
      },
    );
  }

  Widget _buildToolItem(
    BuildContext context, {
    required String title,
    required IconData icon,
    required String route,
    required ColorScheme colorScheme,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, route),
        borderRadius: BorderRadius.circular(14),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHigh,
                shape: BoxShape.circle,
                border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.4)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(icon, size: 23, color: colorScheme.primary),
            ),
            const SizedBox(height: 7),
            Text(
              title,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
                height: 1.15,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // --- 6. Learn & Explore (Tajweed, Kalmas, Hajj, Zakat) ---
  Widget _buildLearningGrid(BuildContext context, ColorScheme colorScheme) {
    final List<Map<String, dynamic>> items = [
      {
        'title': 'Tajweed Rules & Waqf',
        'subtitle': 'Pronunciation & Stop Signs',
        'icon': Icons.record_voice_over_rounded,
        'route': AppRoutes.tajweedRules,
      },
      {
        'title': '6 Kalmas of Islam',
        'subtitle': 'With Urdu & Eng Translation',
        'icon': Icons.collections_bookmark_rounded,
        'route': AppRoutes.kalmas,
      },
      {
        'title': 'Hajj & Umrah Guide',
        'subtitle': 'Step-by-step Pilgrimage',
        'icon': Icons.mosque_rounded,
        'route': AppRoutes.hajjGuide,
      },
      {
        'title': 'Zakat Calculator',
        'subtitle': 'Gold, Silver & Wealth Nisab',
        'icon': Icons.calculate_rounded,
        'route': AppRoutes.zakatCalculator,
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 2.2,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => Navigator.pushNamed(context, item['route'] as String),
              borderRadius: BorderRadius.circular(14),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(item['icon'] as IconData, size: 19, color: colorScheme.primary),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['title'] as String,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11.5,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item['subtitle'] as String,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 9.5,
                              color: colorScheme.onSurface.withValues(alpha: 0.55),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // --- 7. Daily Inspiration Card ---
  Widget _buildDailyInspirationCard(BuildContext context, ColorScheme colorScheme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppConstants.gold.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.format_quote_rounded, color: AppConstants.gold, size: 20),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        'Daily Inspiration',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12.5,
                          fontWeight: FontWeight.bold,
                          color: AppConstants.gold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () => Navigator.pushNamed(context, AppRoutes.dailyAyah),
                borderRadius: BorderRadius.circular(6),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  child: Text(
                    'Daily Ayah',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '\"The best among you are those who learn the Quran and teach it.\"',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              fontStyle: FontStyle.italic,
              color: colorScheme.onSurface.withValues(alpha: 0.9),
              height: 1.45,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '— Prophet Muhammad ﷺ (Sahih al-Bukhari 5027)',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11.5,
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  // --- Helper: Section Header ---
  Widget _buildSectionHeader(
    BuildContext context, {
    required String title,
    required String arabicTitle,
    required IconData icon,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Row(
            children: [
              Icon(icon, size: 17, color: colorScheme.primary),
              const SizedBox(width: 7),
              Flexible(
                child: Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15.5,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                    letterSpacing: -0.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          arabicTitle,
          style: TextStyle(
            fontFamily: AppConstants.uthmaniFont,
            fontSize: 13,
            color: colorScheme.primary.withValues(alpha: 0.75),
          ),
        ),
      ],
    );
  }
}
