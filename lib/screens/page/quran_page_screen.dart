import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/mushaf_16_line_model.dart';
import '../../models/resume_data.dart';
import '../../providers/quran_provider.dart';
import '../../providers/settings_provider.dart';
import '../../core/constants/constants.dart';
import '../../core/widgets/mushaf_page_frame.dart';
import '../../core/widgets/mushaf_16_line_view.dart';
import '../../core/widgets/loading_error_widget.dart';
import 'package:tajweed_quran/services/mushaf_16_line_layout_service.dart';
import 'package:tajweed_quran/services/audio_manager_service.dart';

class QuranPageScreen extends StatefulWidget {
  final int initialPage;
  const QuranPageScreen({super.key, this.initialPage = 1});

  @override
  State<QuranPageScreen> createState() => _QuranPageScreenState();
}

class _QuranPageScreenState extends State<QuranPageScreen> {
  late PageController _pageController;
  late int _currentPage;
  bool _showControls = true;
  final _layoutService = Mushaf16LineLayoutService.instance;
  late Future<List<Mushaf16LinePage>> _buildFuture;
  late final AudioManagerService _audioManager;
  bool _isControllerInitialized = false;

  @override
  void initState() {
    super.initState();
    _audioManager = AudioManagerService.instance;
    _currentPage = widget.initialPage.clamp(1, 549);
    _buildFuture = _initPages();
    _audioManager.addListener(_onAudioStateChanged);
  }

  @override
  void dispose() {
    _audioManager.removeListener(_onAudioStateChanged);
    if (_isControllerInitialized) _pageController.dispose();
    super.dispose();
  }

  void _onAudioStateChanged() {
    if (!mounted || !_isControllerInitialized) return;
    final audioPage = _audioManager.currentPageNumber;
    if (audioPage != null && audioPage != _currentPage) {
      if (_pageController.hasClients && _pageController.page?.round() != (audioPage - 1)) {
        _pageController.animateToPage(
          audioPage - 1,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOutCubic,
        );
      }
    }
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
  }

  Future<List<Mushaf16LinePage>> _initPages() async {
    final repo = context.read<QuranProvider>().repository;
    
    // Ensure all 30 Paras are loaded for consistent pagination
    if (!_layoutService.isReady) {
      final surahs = await repo.getAllSurahs();
      final allAyahs = await repo.ensureAllAyahsLoaded();
      _layoutService.buildAllPages(surahs: surahs, allAyahs: allAyahs);
    }

    final pages = _layoutService.buildAllPages(surahs: [], allAyahs: []);
    _pageController = PageController(initialPage: _currentPage - 1);
    _isControllerInitialized = true;
    
    return pages;
  }

  @override
  Widget build(BuildContext context) {
    final quranProvider = context.watch<QuranProvider>();
    final settings = context.watch<SettingsProvider>();

    return FutureBuilder<List<Mushaf16LinePage>>(
      future: _buildFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFF07241C),
            body: Center(child: LoadingErrorWidget(isLoading: true, child: SizedBox.shrink())),
          );
        }

        final pages = snapshot.data ?? [];
        if (pages.isEmpty) {
          return Scaffold(
            backgroundColor: const Color(0xFF07241C),
            appBar: AppBar(backgroundColor: const Color(0xFF0D3B2E), title: const Text('16-Line Mushaf')),
            body: const Center(child: Text('Unable to load Mushaf pages', style: TextStyle(color: Colors.white))),
          );
        }

        return PageView.builder(
          controller: _pageController,
          onPageChanged: (idx) {
            setState(() {
              _currentPage = idx + 1;
            });
            final page = pages[idx];
            quranProvider.saveResume(ResumeData(
              surahName: page.surahName,
              surahNumber: page.surahNumber,
              ayahNumber: 1,
              page: page.pageNumber,
              juz: page.juzNumber,
              lastRead: DateTime.now(),
            ));
          },
          physics: const BouncingScrollPhysics(),
          reverse: true, // Authentic R-to-L flipping
          itemCount: pages.length,
          allowImplicitScrolling: true,
          itemBuilder: (context, index) {
            final page = pages[index];
            final isRead = quranProvider.getPageReadStatus(page.pageNumber);

            return MushafPageFrame(
              pageNumber: page.pageNumber,
              totalPages: 549,
              surahNameArabic: page.surahName,
              juzNameArabic: 'الجزء ${page.juzNumber}',
              isRead: isRead,
              showControls: _showControls,
              onTap: _toggleControls,
              onReadChanged: (val) {
                quranProvider.togglePageReadStatus(page.pageNumber);
              },
              child: Mushaf16LineView(
                page: page,
                fontSize: settings.arabicFontSize,
                fontFamily: settings.arabicFontFamily,
                showTajweed: settings.showTajweed,
              ),
            );
          },
        );
      },
    );
  }
}
