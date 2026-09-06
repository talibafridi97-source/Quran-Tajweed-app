import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/constants.dart';
import '../../providers/quran_provider.dart';
import '../../services/mushaf_16_line_layout_service.dart';
import '../surah/surah_list_screen.dart';
import '../juz/juz_list_screen.dart';
import '../page/quran_page_screen.dart';

class QuranHubScreen extends StatefulWidget {
  const QuranHubScreen({super.key});

  @override
  State<QuranHubScreen> createState() => _QuranHubScreenState();
}

class _QuranHubScreenState extends State<QuranHubScreen>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late TabController _tabController;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final totalPages = Mushaf16LineLayoutService.instance.totalPages;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: isDark ? AppConstants.surfaceDark : Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppConstants.primaryGreen.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.menu_book_rounded, color: AppConstants.primaryGreen, size: 18),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                'Holy Quran (القرآن الكريم)',
                style: GoogleFonts.plusJakartaSans(
                  color: isDark ? AppConstants.textPrimaryDark : AppConstants.primaryGreen,
                  fontWeight: FontWeight.w800,
                  fontSize: 17,
                  letterSpacing: -0.3,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => Navigator.pushNamed(context, '/search'),
            tooltip: 'Search Quran',
            icon: Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : AppConstants.primaryGreen.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search_rounded,
                size: 19,
                color: isDark ? AppConstants.gold : AppConstants.primaryGreen,
              ),
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pushNamed(context, '/bookmarks-notes'),
            tooltip: 'Saved & Notes',
            icon: Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : AppConstants.primaryGreen.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.bookmarks_rounded,
                size: 19,
                color: isDark ? AppConstants.gold : AppConstants.primaryGreen,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: isDark ? AppConstants.surfaceVariantDark : AppConstants.surfaceVariantLight,
              borderRadius: BorderRadius.circular(14),
            ),
            child: TabBar(
              controller: _tabController,
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              indicator: BoxDecoration(
                color: AppConstants.primaryGreen,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppConstants.primaryGreen.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              labelColor: Colors.white,
              unselectedLabelColor: isDark ? AppConstants.textSecondaryDark : AppConstants.textSecondaryLight,
              labelStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 13),
              unselectedLabelStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, fontSize: 13),
              tabs: [
                const Tab(text: '114 Surahs'),
                const Tab(text: '30 Paras'),
                Tab(text: '$totalPages Pages'),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _KeepAliveTab(child: SurahListScreen()),
          _KeepAliveTab(child: JuzListScreen()),
          _KeepAliveTab(child: _MushafPagesOverviewTab()),
        ],
      ),
    );
  }
}

class _KeepAliveTab extends StatefulWidget {
  final Widget child;
  const _KeepAliveTab({required this.child});

  @override
  State<_KeepAliveTab> createState() => _KeepAliveTabState();
}

class _KeepAliveTabState extends State<_KeepAliveTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}

class _MushafPagesOverviewTab extends StatefulWidget {
  const _MushafPagesOverviewTab();

  @override
  State<_MushafPagesOverviewTab> createState() => _MushafPagesOverviewTabState();
}

class _MushafPagesOverviewTabState extends State<_MushafPagesOverviewTab> {
  final TextEditingController _searchController = TextEditingController();
  int _searchPage = 0;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final quranProvider = context.watch<QuranProvider>();
    final resume = quranProvider.resumeData;
    final lastReadPage = resume?.page ?? 1;
    final totalPages = Mushaf16LineLayoutService.instance.totalPages;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      physics: const BouncingScrollPhysics(),
      children: [
        // Resume Mushaf Card
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppConstants.deepEmerald, AppConstants.primaryGreen, Color(0xFF0F5A47)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppConstants.gold.withValues(alpha: 0.3), width: 1),
            boxShadow: [
              BoxShadow(
                color: AppConstants.deepEmerald.withValues(alpha: 0.4),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Flexible(
                    child: Row(
                      children: [
                        Icon(Icons.auto_stories_rounded, color: AppConstants.gold, size: 20),
                        SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            '16-Line Quran Mushaf',
                            style: TextStyle(color: Colors.white70, fontSize: 12.5, fontWeight: FontWeight.w600),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
                    decoration: BoxDecoration(
                      color: AppConstants.gold.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppConstants.gold.withValues(alpha: 0.4), width: 0.8),
                    ),
                    child: Text(
                      'Page $lastReadPage',
                      style: const TextStyle(color: AppConstants.goldLight, fontWeight: FontWeight.bold, fontSize: 11.5),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                'Continue Mushaf Reading',
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 3),
              Text(
                'Resume from Page $lastReadPage (${resume?.surahName ?? 'Surah Al-Fatihah'})',
                style: const TextStyle(color: Colors.white70, fontSize: 12.5),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 14),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => QuranPageScreen(initialPage: lastReadPage),
                    ),
                  );
                },
                icon: const Icon(Icons.menu_book_rounded, size: 18),
                label: const Text('Open Mushaf Reader'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.gold,
                  foregroundColor: Colors.black87,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 18),

        // Quick Jump Bar
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _searchController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Jump to page (1 - $totalPages)...',
                  prefixIcon: const Icon(Icons.search, size: 20),
                  filled: true,
                  fillColor: isDark ? AppConstants.surfaceDark : Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.grey[200]!,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppConstants.gold, width: 1.5),
                  ),
                ),
                onChanged: (val) {
                  setState(() {
                    _searchPage = int.tryParse(val) ?? 0;
                  });
                },
              ),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed: () {
                final p = _searchPage.clamp(1, totalPages);
                if (p >= 1 && p <= totalPages) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => QuranPageScreen(initialPage: p)),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.primaryGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('Go', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),

        const SizedBox(height: 20),

        Text(
          'Quick Page Grid',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 15.5,
            fontWeight: FontWeight.bold,
            color: isDark ? AppConstants.textPrimaryDark : AppConstants.textPrimaryLight,
          ),
        ),
        const SizedBox(height: 10),

        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 1.15,
          ),
          itemCount: totalPages,
          itemBuilder: (context, index) {
            final pageNum = index + 1;
            final isRead = quranProvider.getPageReadStatus(pageNum);
            final isCurrent = pageNum == lastReadPage;

            return InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => QuranPageScreen(initialPage: pageNum),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(10),
              child: Container(
                decoration: BoxDecoration(
                  color: isCurrent
                      ? AppConstants.primaryGreen
                      : isRead
                          ? AppConstants.accentGreen.withValues(alpha: isDark ? 0.2 : 0.12)
                          : isDark
                              ? AppConstants.surfaceDark
                              : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isCurrent
                        ? AppConstants.gold
                        : isRead
                            ? AppConstants.accentGreen
                            : isDark
                                ? Colors.white.withValues(alpha: 0.08)
                                : Colors.grey[200]!,
                    width: isCurrent ? 1.5 : 1,
                  ),
                ),
                child: Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Padding(
                      padding: const EdgeInsets.all(3.0),
                      child: Text(
                        '$pageNum',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12.5,
                          color: isCurrent
                              ? AppConstants.goldLight
                              : isRead
                                  ? (isDark ? AppConstants.accentGreen : AppConstants.primaryGreen)
                                  : (isDark ? Colors.white70 : Colors.black87),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),

        const SizedBox(height: 80),
      ],
    );
  }
}
