import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/mushaf_16_line_model.dart';
import '../../models/resume_data.dart';
import '../../providers/quran_provider.dart';
import '../../providers/settings_provider.dart';
import '../../core/widgets/mushaf_page_frame.dart';
import '../../core/widgets/mushaf_16_line_view.dart';
import '../../core/widgets/loading_error_widget.dart';
import '../../services/mushaf_16_line_layout_service.dart';
import '../../services/audio_manager_service.dart';

class JuzDetailScreen extends StatefulWidget {
  final int juzNumber;
  const JuzDetailScreen({super.key, required this.juzNumber});

  @override
  State<JuzDetailScreen> createState() => _JuzDetailScreenState();
}

class _JuzDetailScreenState extends State<JuzDetailScreen> {
  late PageController _pageController;
  final _layoutService = Mushaf16LineLayoutService.instance;
  late Future<List<Mushaf16LinePage>> _buildFuture;
  bool _showControls = true;
  late final AudioManagerService _audioManager;
  bool _isControllerInitialized = false;

  @override
  void initState() {
    super.initState();
    _audioManager = AudioManagerService.instance;
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
    if (audioPage != null) {
      if (_pageController.hasClients) {
        final target = audioPage - 1;
        if (target >= 0) {
           _pageController.animateToPage(
              target,
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeInOutCubic,
            );
        }
      }
    }
  }

  Future<List<Mushaf16LinePage>> _initPages() async {
    final repo = context.read<QuranProvider>().repository;
    
    // Ensure all 30 Paras are loaded for consistent pagination
    final surahs = await repo.getAllSurahs();
    final allAyahs = await repo.ensureAllAyahsLoaded();
    
    final pages = _layoutService.buildAllPages(surahs: surahs, allAyahs: allAyahs);
    
    if (pages.isEmpty) return [];

    final startPage = _layoutService.getJuzStartPage(widget.juzNumber);
    _pageController = PageController(initialPage: (startPage - 1).clamp(0, pages.length - 1));
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
            appBar: AppBar(backgroundColor: const Color(0xFF0D3B2E), title: Text('Para ${widget.juzNumber}')),
            body: const Center(child: Text('Unable to load Mushaf pages', style: TextStyle(color: Colors.white))),
          );
        }

        return PageView.builder(
          controller: _pageController,
          itemCount: pages.length,
          reverse: true, // Professional Indo-Pak R-to-L navigation
          allowImplicitScrolling: true,
          onPageChanged: (idx) {
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
              onTap: () => setState(() => _showControls = !_showControls),
              onNextPage: () {
                if (_pageController.hasClients) {
                  _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                }
              },
              onPreviousPage: () {
                if (_pageController.hasClients) {
                  _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                }
              },
              onReadChanged: (val) => quranProvider.togglePageReadStatus(page.pageNumber),
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
