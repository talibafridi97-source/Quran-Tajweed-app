import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/ayah.dart';
import '../../models/juz_model.dart';
import '../../models/resume_data.dart';
import '../../providers/quran_provider.dart';
import '../../providers/settings_provider.dart';
import '../../core/constants/constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/tajweed_text.dart';
import '../../core/widgets/loading_error_widget.dart';

class JuzDetailScreen extends StatefulWidget {
  final int juzNumber;
  const JuzDetailScreen({super.key, required this.juzNumber});

  @override
  State<JuzDetailScreen> createState() => _JuzDetailScreenState();
}

class _JuzDetailScreenState extends State<JuzDetailScreen> {
  late Future<List<Ayah>> _juzFuture;
  bool _isPageViewMode = false;
  PageController? _pageController;
  int _currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadJuzData();
  }

  @override
  void dispose() {
    _pageController?.dispose();
    super.dispose();
  }

  void _loadJuzData() {
    final repository = context.read<QuranProvider>().repository;
    _juzFuture = repository.getJuzTajweed(widget.juzNumber);
  }

  // Group ayahs by actual API page number
  Map<int, List<Ayah>> _groupAyahsByPage(List<Ayah> ayahs) {
    final Map<int, List<Ayah>> grouped = {};
    for (final ayah in ayahs) {
      grouped.putIfAbsent(ayah.page, () => []).add(ayah);
    }
    return grouped;
  }

  // Group ayahs within a page by Surah
  Map<int, List<Ayah>> _groupAyahsBySurah(List<Ayah> ayahs) {
    final Map<int, List<Ayah>> grouped = {};
    for (final ayah in ayahs) {
      final sNum = ayah.surahNumber ?? 1;
      grouped.putIfAbsent(sNum, () => []).add(ayah);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final quranProvider = context.read<QuranProvider>();

    final juzMeta = JuzModel.allJuz.firstWhere(
      (j) => j.number == widget.juzNumber,
      orElse: () => JuzModel(
        number: widget.juzNumber,
        nameArabic: 'الجزء ${widget.juzNumber}',
        nameEnglish: 'Juz ${widget.juzNumber}',
        startPage: 1,
      ),
    );

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Para ${widget.juzNumber} - ${juzMeta.nameEnglish}'),
        backgroundColor: AppConstants.primaryGreen,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(_isPageViewMode ? Icons.view_headline : Icons.auto_stories),
            tooltip: _isPageViewMode ? 'Continuous Scroll' : 'Page-by-Page View',
            onPressed: () {
              setState(() {
                _isPageViewMode = !_isPageViewMode;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.bookmark_add_outlined),
            tooltip: 'Bookmark Position',
            onPressed: () {
              quranProvider.saveResume(ResumeData(
                surahName: juzMeta.nameEnglish,
                surahNumber: 1,
                ayahNumber: 1,
                page: juzMeta.startPage,
                juz: widget.juzNumber,
                lastRead: DateTime.now(),
              ));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Saved Para ${widget.juzNumber} as last read position')),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Ayah>>(
        future: _juzFuture,
        builder: (context, snapshot) {
          final isLoading = snapshot.connectionState == ConnectionState.waiting;
          final hasError = snapshot.hasError;
          final ayahs = snapshot.data ?? [];
          final isEmpty = !isLoading && !hasError && ayahs.isEmpty;

          if (isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.menu_book_rounded, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'No Quran content found for Para ${widget.juzNumber}.',
                    style: const TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => setState(() => _loadJuzData()),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reload Para Data'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConstants.primaryGreen,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            );
          }

          if (isLoading || hasError) {
            return LoadingErrorWidget(
              isLoading: isLoading,
              errorMessage: hasError ? snapshot.error.toString() : null,
              onRetry: () => setState(() => _loadJuzData()),
              child: const SizedBox.shrink(),
            );
          }

          final pageMap = _groupAyahsByPage(ayahs);
          final pageNumbers = pageMap.keys.toList()..sort();

          if (_isPageViewMode) {
            _pageController ??= PageController(initialPage: _currentPageIndex);
            return Column(
              children: [
                // Top Page Indicator & Navigation Bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: AppConstants.primaryGreen.withOpacity(0.08),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Page ${pageNumbers[_currentPageIndex]} of ${pageNumbers.last}',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppConstants.primaryGreen),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back_ios, size: 18),
                            onPressed: _currentPageIndex > 0
                                ? () {
                                    _pageController?.previousPage(
                                      duration: const Duration(milliseconds: 300),
                                      curve: Curves.easeInOut,
                                    );
                                  }
                                : null,
                          ),
                          IconButton(
                            icon: const Icon(Icons.arrow_forward_ios, size: 18),
                            onPressed: _currentPageIndex < pageNumbers.length - 1
                                ? () {
                                    _pageController?.nextPage(
                                      duration: const Duration(milliseconds: 300),
                                      curve: Curves.easeInOut,
                                    );
                                  }
                                : null,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // PageView for Mushaf Pages
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: pageNumbers.length,
                    onPageChanged: (idx) {
                      setState(() {
                        _currentPageIndex = idx;
                      });
                    },
                    itemBuilder: (context, idx) {
                      final pageNum = pageNumbers[idx];
                      final pageAyahs = pageMap[pageNum] ?? [];
                      return _buildPageCard(context, settings, pageNum, pageAyahs, juzMeta);
                    },
                  ),
                ),
              ],
            );
          }

          // Continuous Vertical Scroll Mode
          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            itemCount: pageNumbers.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return _buildJuzHeader(juzMeta, ayahs.length, pageNumbers.length);
              }

              final pageNum = pageNumbers[index - 1];
              final pageAyahs = pageMap[pageNum] ?? [];
              return _buildPageCard(context, settings, pageNum, pageAyahs, juzMeta);
            },
          );
        },
      ),
    );
  }

  Widget _buildJuzHeader(JuzModel juz, int totalAyahs, int totalPages) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppTheme.brandGradient,
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
        children: [
          Text(
            juz.nameArabic,
            style: const TextStyle(
              fontFamily: AppConstants.uthmaniFont,
              fontSize: 36,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Para ${juz.number} • ${juz.nameEnglish} • $totalAyahs Ayahs • $totalPages Mushaf Pages',
            style: const TextStyle(color: Colors.white70, fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPageCard(
    BuildContext context,
    SettingsProvider settings,
    int pageNum,
    List<Ayah> pageAyahs,
    JuzModel juzMeta,
  ) {
    final surahGroups = _groupAyahsBySurah(pageAyahs);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Page Header Indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppConstants.primaryGreen.withOpacity(0.06),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppConstants.primaryGreen.withOpacity(0.15)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Mushaf Page $pageNum',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: AppConstants.primaryGreen,
                  ),
                ),
                Text(
                  'Para ${juzMeta.number}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: AppConstants.gold,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Render Ayahs grouped by Surah within this Mushaf Page
          ...surahGroups.entries.map((entry) {
            final sNum = entry.key;
            final sAyahs = entry.value;
            final firstAyah = sAyahs.first;
            final surahName = firstAyah.surahName ?? 'سورة';
            final surahEngName = firstAyah.surahEnglishName ?? '';

            return Column(
              children: [
                // Surah Banner if this page includes Ayah 1 or starts a Surah
                if (firstAyah.numberInSurah == 1) ...[
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppConstants.primaryGreen,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          surahEngName.isNotEmpty ? surahEngName : 'Surah $sNum',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          surahName,
                          style: const TextStyle(
                            fontFamily: AppConstants.uthmaniFont,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (sNum != 1 && sNum != 9) ...[
                    const SizedBox(height: 8),
                    const Text(
                      'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                      style: TextStyle(
                        fontFamily: AppConstants.uthmaniFont,
                        fontSize: 24,
                        color: AppConstants.primaryGreen,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                  ],
                ],

                // Ayahs Text
                Directionality(
                  textDirection: TextDirection.rtl,
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 4,
                    runSpacing: 12,
                    children: sAyahs.map((ayah) {
                      return TajweedText(
                        rawText: '${ayah.text} ',
                        fontSize: settings.arabicFontSize,
                        fontFamily: AppConstants.uthmaniFont,
                        ayahNumber: ayah.numberInSurah,
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            );
          }),
        ],
      ),
    );
  }
}
