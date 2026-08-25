import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/constants.dart';
import '../../providers/quran_provider.dart';
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Holy Quran (القرآن الكريم)',
          style: GoogleFonts.plusJakartaSans(
            color: AppConstants.primaryGreen,
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => Navigator.pushNamed(context, '/search'),
            tooltip: 'Search Quran',
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppConstants.primaryGreen.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.search_rounded, size: 20, color: AppConstants.primaryGreen),
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pushNamed(context, '/bookmarks-notes'),
            tooltip: 'Saved & Notes',
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppConstants.primaryGreen.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.bookmarks_rounded, size: 20, color: AppConstants.primaryGreen),
            ),
          ),
          const SizedBox(width: 8),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppConstants.primaryGreen,
          unselectedLabelColor: Colors.grey[500],
          indicatorColor: AppConstants.primaryGreen,
          indicatorWeight: 3,
          labelStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 14),
          unselectedLabelStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, fontSize: 14),
          tabs: const [
            Tab(text: '114 Surahs'),
            Tab(text: '30 Paras'),
            Tab(text: '604 Pages'),
          ],
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
    final quranProvider = context.watch<QuranProvider>();
    final resume = quranProvider.resumeData;
    final lastReadPage = resume?.page ?? 1;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      physics: const BouncingScrollPhysics(),
      children: [
        // Resume Mushaf Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppConstants.primaryGreen, Color(0xFF007A72)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppConstants.primaryGreen.withOpacity(0.3),
                blurRadius: 15,
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
                  const Row(
                    children: [
                      Icon(Icons.auto_stories_rounded, color: AppConstants.gold, size: 22),
                      SizedBox(width: 8),
                      Text(
                        '15-Line Madani Mushaf',
                        style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppConstants.gold.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Page $lastReadPage / 604',
                      style: const TextStyle(color: AppConstants.gold, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Continue Mushaf Reading',
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Resume from Page $lastReadPage (${resume?.surahName ?? 'Surah Al-Fatihah'})',
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 16),
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
                  backgroundColor: Colors.white,
                  foregroundColor: AppConstants.primaryGreen,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Quick Jump Bar
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _searchController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Jump to page (1 - 604)...',
                  prefixIcon: const Icon(Icons.search, size: 20),
                  filled: true,
                  fillColor: Colors.grey[100],
                  contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (val) {
                  setState(() {
                    _searchPage = int.tryParse(val) ?? 0;
                  });
                },
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: () {
                final p = _searchPage.clamp(1, 604);
                if (p >= 1 && p <= 604) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => QuranPageScreen(initialPage: p)),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.primaryGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('Go', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),

        const SizedBox(height: 24),

        const Text(
          'Quick Page Grid',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),

        // Grid of pages
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.1,
          ),
          itemCount: 604,
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
              borderRadius: BorderRadius.circular(12),
              child: Container(
                decoration: BoxDecoration(
                  color: isCurrent
                      ? AppConstants.primaryGreen
                      : isRead
                          ? AppConstants.accentGreen.withOpacity(0.12)
                          : Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isCurrent
                        ? AppConstants.primaryGreen
                        : isRead
                            ? AppConstants.accentGreen
                            : Colors.grey[200]!,
                    width: isCurrent ? 1.5 : 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    '$pageNum',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: isCurrent
                          ? Colors.white
                          : isRead
                              ? AppConstants.primaryGreen
                              : Colors.black87,
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
