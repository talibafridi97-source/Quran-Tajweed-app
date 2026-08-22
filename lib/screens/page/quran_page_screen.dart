import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/ayah.dart';
import '../../models/quran_word.dart';
import '../../providers/quran_provider.dart';
import '../../core/widgets/mushaf_line_view.dart';
import '../../core/widgets/mushaf_page_frame.dart';
import '../../core/widgets/loading_error_widget.dart';
import '../../services/qcf_font_manager.dart';
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
  late Future<void> _fontFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _pageFuture = widget.quranProvider.repository.getPageQcfV2(widget.pageNumber);
    _fontFuture = QcfFontManager.loadPageFont(widget.pageNumber);
    // Prefetch next and previous page fonts in background
    QcfFontManager.prefetchAdjacentFonts(widget.pageNumber);
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

        // Collect all words and group by line_number (1..15)
        final Map<int, List<QuranWord>> lineMap = {};
        for (final ayah in ayahs) {
          for (final word in ayah.words) {
            final line = word.lineNumber ?? 1;
            lineMap.putIfAbsent(line, () => []).add(word);
          }
        }

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
            child: FutureBuilder<void>(
              future: _fontFuture,
              builder: (context, fontSnap) {
                if (fontSnap.connectionState == ConnectionState.waiting &&
                    !QcfFontManager.isFontLoaded(widget.pageNumber)) {
                  return const SizedBox(
                    height: 480,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppConstants.primaryGreen,
                        strokeWidth: 2,
                      ),
                    ),
                  );
                }

                // Check if this page starts a new Surah
                final hasSurahStart = ayahs.any((a) => a.numberInSurah == 1);
                final startAyah = hasSurahStart ? ayahs.firstWhere((a) => a.numberInSurah == 1) : null;
                final startSurahNum = startAyah?.surahNumber ?? surahNum ?? 1;
                final startSurahName = startAyah?.surahName ?? surahName;

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // If Surah starts on this page, render illuminated Surah Header
                    if (hasSurahStart) ...[
                      _buildIlluminatedSurahHeader(startSurahName, startSurahNum),
                      if (startSurahNum != 1 && startSurahNum != 9) ...[
                        const SizedBox(height: 4),
                        _buildIlluminatedBismillah(),
                        const SizedBox(height: 6),
                      ],
                    ],

                    // Render the 15 fixed Madani Mushaf lines
                    ...List.generate(15, (index) {
                      final lineNum = index + 1;
                      final lineWords = lineMap[lineNum] ?? [];
                      if (lineWords.isEmpty && hasSurahStart && lineNum <= 3) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2.0),
                        child: MushafLineView(
                          pageNumber: widget.pageNumber,
                          lineNumber: lineNum,
                          words: lineWords,
                          fontSize: 21.5,
                        ),
                      );
                    }),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildIlluminatedSurahHeader(String name, int sNum) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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
                fontSize: 20,
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
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F1E5),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFC9A227), width: 1),
      ),
      child: const Text(
        'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ',
        style: TextStyle(
          fontFamily: AppConstants.uthmaniFont,
          fontSize: 20,
          color: Color(0xFF144747),
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
