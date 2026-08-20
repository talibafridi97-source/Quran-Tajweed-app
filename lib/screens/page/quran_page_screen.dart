import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/ayah.dart';
import '../../providers/quran_provider.dart';
import '../../core/widgets/tajweed_text.dart';
import '../../core/widgets/mushaf_page_frame.dart';
import '../../core/widgets/loading_error_widget.dart';
import '../../models/resume_data.dart';
import '../../core/constants/constants.dart';

class QuranPageScreen extends StatefulWidget {
  final int initialPage;
  const QuranPageScreen({super.key, this.initialPage = 1});

  @override
  State<QuranPageScreen> createState() => _QuranPageScreenState();
}

class _QuranPageScreenState extends State<QuranPageScreen> {
  late PageController _pageController;
  late int _currentPage;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialPage.clamp(1, 604);
    _pageController = PageController(initialPage: _currentPage - 1);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index + 1;
    });
  }

  void _showJumpToPageDialog() {
    final textController = TextEditingController(text: '$_currentPage');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Go to Page'),
        content: TextField(
          controller: textController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            hintText: 'Enter page number (1-604)',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final page = int.tryParse(textController.text);
              if (page != null && page >= 1 && page <= 604) {
                _pageController.jumpToPage(page - 1);
                Navigator.pop(context);
              }
            },
            child: const Text('Go'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final quranProvider = context.watch<QuranProvider>();

    return PageView.builder(
      controller: _pageController,
      onPageChanged: _onPageChanged,
      reverse: true, // Right-to-left page flipping for Arabic Mushaf
      itemCount: 604,
      itemBuilder: (context, index) {
        final pageNum = index + 1;
        return _SingleMushafPage(
          pageNumber: pageNum,
          onJumpRequested: _showJumpToPageDialog,
          quranProvider: quranProvider,
        );
      },
    );
  }
}

class _SingleMushafPage extends StatefulWidget {
  final int pageNumber;
  final VoidCallback onJumpRequested;
  final QuranProvider quranProvider;

  const _SingleMushafPage({
    required this.pageNumber,
    required this.onJumpRequested,
    required this.quranProvider,
  });

  @override
  State<_SingleMushafPage> createState() => _SingleMushafPageState();
}

class _SingleMushafPageState extends State<_SingleMushafPage> {
  late Future<List<Ayah>> _pageFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _pageFuture = widget.quranProvider.repository.getPageTajweed(widget.pageNumber);
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
    final isRead = widget.quranProvider.getPageReadStatus(widget.pageNumber);

    return FutureBuilder<List<Ayah>>(
      future: _pageFuture,
      builder: (context, snapshot) {
        final isLoading = snapshot.connectionState == ConnectionState.waiting;
        final hasError = snapshot.hasError;
        final ayahs = snapshot.data ?? [];

        String surahName = 'سورة';
        int? surahNum;
        int? juzNum;

        if (ayahs.isNotEmpty) {
          surahNum = ayahs.first.surahNumber;
          surahName = ayahs.first.surahName ?? 'سورة';
          juzNum = ayahs.first.juz;

          // Save last read point automatically
          WidgetsBinding.instance.addPostFrameCallback((_) {
            widget.quranProvider.saveResume(ResumeData(
              surahName: surahName,
              surahNumber: surahNum ?? 1,
              ayahNumber: ayahs.first.numberInSurah,
              page: widget.pageNumber,
              juz: juzNum ?? 1,
              lastRead: DateTime.now(),
            ));
          });
        }

        final surahGroups = _groupAyahsBySurah(ayahs);

        return MushafPageFrame(
          pageNumber: widget.pageNumber,
          surahNameArabic: surahName,
          juzNameArabic: juzNum != null ? 'الجزء $juzNum' : null,
          isRead: isRead,
          onReadChanged: (val) {
            widget.quranProvider.togglePageReadStatus(widget.pageNumber);
          },
          onBookmarkPressed: widget.onJumpRequested,
          child: LoadingErrorWidget(
            isLoading: isLoading,
            errorMessage: hasError ? snapshot.error.toString() : null,
            onRetry: () {
              setState(() {
                _loadData();
              });
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: surahGroups.entries.map((entry) {
                final sNum = entry.key;
                final sAyahs = entry.value;
                final firstAyah = sAyahs.first;
                final currentSurahName = firstAyah.surahName ?? 'سورة';

                List<Ayah> processedAyahs = sAyahs;
                if (sNum != 1 && sAyahs.isNotEmpty && firstAyah.numberInSurah == 1) {
                  if (firstAyah.text.startsWith('بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ')) {
                    final cleanText = firstAyah.text.replaceFirst(RegExp(r'^بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ\s*'), '');
                    if (cleanText.isNotEmpty) {
                      processedAyahs = [
                        Ayah(
                          number: firstAyah.number,
                          text: cleanText,
                          numberInSurah: firstAyah.numberInSurah,
                          juz: firstAyah.juz,
                          manzil: firstAyah.manzil,
                          page: firstAyah.page,
                          ruku: firstAyah.ruku,
                          hizbQuarter: firstAyah.hizbQuarter,
                          sajda: firstAyah.sajda,
                          surahNumber: firstAyah.surahNumber,
                          surahName: firstAyah.surahName,
                          surahEnglishName: firstAyah.surahEnglishName,
                        ),
                        ...sAyahs.skip(1),
                      ];
                    }
                  }
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // If Surah starts on this page, render illuminated Surah Header
                    if (firstAyah.numberInSurah == 1) ...[
                      _buildIlluminatedSurahHeader(currentSurahName, sNum),
                      if (sNum != 1 && sNum != 9) ...[
                        const SizedBox(height: 8),
                        _buildIlluminatedBismillah(),
                        const SizedBox(height: 12),
                      ],
                    ],

                    // Page Text with authentic Tajweed styling
                    TajweedText(
                      ayahs: processedAyahs,
                      fontSize: 23,
                      fontFamily: AppConstants.uthmaniFont,
                      textAlign: TextAlign.justify,
                    ),
                    const SizedBox(height: 8),
                  ],
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildIlluminatedSurahHeader(String name, int sNum) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F1E5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF2C7A9E), width: 2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFC9A227).withOpacity(0.25),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Container(
        margin: const EdgeInsets.all(2),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFC9A227), width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF2C7A9E),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'مَدَنِيَّةٌ',
                style: TextStyle(
                  fontFamily: AppConstants.uthmaniFont,
                  fontSize: 12,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Text(
              'سُورَةُ $name',
              style: const TextStyle(
                fontFamily: AppConstants.uthmaniFont,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF144747),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF2C7A9E),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'رقم $sNum',
                style: const TextStyle(
                  fontFamily: AppConstants.uthmaniFont,
                  fontSize: 12,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIlluminatedBismillah() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F1E5),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFC9A227), width: 1),
      ),
      child: const Text(
        'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ',
        style: TextStyle(
          fontFamily: AppConstants.uthmaniFont,
          fontSize: 22,
          color: Color(0xFF144747),
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
