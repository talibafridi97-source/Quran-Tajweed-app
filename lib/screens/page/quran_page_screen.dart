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
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 2,
              runSpacing: 8,
              children: ayahs.map((a) {
                return TajweedText(
                  rawText: '${a.text} ',
                  fontSize: 22,
                  fontFamily: AppConstants.uthmaniFont,
                  ayahNumber: a.numberInSurah,
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}
