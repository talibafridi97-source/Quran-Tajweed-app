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
import '../../services/mushaf_16_line_layout_service.dart';
import '../../services/audio_manager_service.dart';

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
    _currentPage = widget.initialPage.clamp(1, 604);
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

  void _onPageChanged(int index) {
    final newPageNumber = index + 1;
    setState(() {
      _currentPage = newPageNumber;
    });

    final page = _layoutService.getPage(newPageNumber);
    if (page != null) {
      context.read<QuranProvider>().saveResume(ResumeData(
            surahName: page.surahName,
            surahNumber: page.surahNumber,
            ayahNumber: 1,
            page: page.pageNumber,
            juz: page.juzNumber,
            lastRead: DateTime.now(),
          ));
    }
  }

  void _showJumpToPageDialog(int totalPages) {
    final textController = TextEditingController(text: '$_currentPage');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Go to Page (1–$totalPages)',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: textController,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Enter page number (1–$totalPages)',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.primaryGreen,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              final pageNum = int.tryParse(textController.text);
              if (pageNum != null && pageNum >= 1 && pageNum <= totalPages) {
                _pageController.animateToPage(
                  pageNum - 1,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOutCubic,
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Go'),
          ),
        ],
      ),
    );
  }

  void _showReadingControlsModal(BuildContext context, SettingsProvider settings) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          return Container(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '16-Line Reading Controls',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const Divider(),
                const SizedBox(height: 8),

                // Font Size Slider
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Quran Font Size', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(
                      '${settings.arabicFontSize.round()} px',
                      style: const TextStyle(color: AppConstants.gold, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Slider(
                  value: settings.arabicFontSize.clamp(20.0, 36.0),
                  min: 20.0,
                  max: 36.0,
                  divisions: 8,
                  activeColor: AppConstants.primaryGreen,
                  inactiveColor: Colors.grey[300],
                  onChanged: (val) {
                    settings.setArabicFontSize(val);
                    setModalState(() {});
                  },
                ),
                const SizedBox(height: 12),

                // Tajweed Toggle
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Tajweed Coloring', style: TextStyle(fontWeight: FontWeight.bold)),
                  value: settings.showTajweed,
                  activeTrackColor: AppConstants.primaryGreen,
                  onChanged: (val) {
                    settings.toggleTajweed(val);
                    setModalState(() {});
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final quranProvider = context.watch<QuranProvider>();
    final settings = context.watch<SettingsProvider>();

    return FutureBuilder<List<Mushaf16LinePage>>(
      future: _buildFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: LoadingErrorWidget(isLoading: true, child: SizedBox.shrink()));
        }

        final pages = snapshot.data ?? [];
        if (pages.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: const Text('16-Line Mushaf')),
            body: const Center(child: Text('Unable to load Mushaf pages.')),
          );
        }

        return PageView.builder(
          controller: _pageController,
          onPageChanged: _onPageChanged,
          physics: const BouncingScrollPhysics(),
          reverse: true, // Authentic R-to-L flipping
          itemCount: pages.length,
          allowImplicitScrolling: true,
          itemBuilder: (context, index) {
            final page = pages[index];
            final isRead = quranProvider.getPageReadStatus(page.pageNumber);

            return MushafPageFrame(
              pageNumber: page.pageNumber,
              totalPages: 604,
              surahNameArabic: page.surahName,
              juzNameArabic: 'الجزء ${page.juzNumber}',
              isRead: isRead,
              showControls: _showControls,
              onTap: _toggleControls,
              onReadChanged: (val) {
                quranProvider.togglePageReadStatus(page.pageNumber);
              },
              onBookmarkPressed: () => _showJumpToPageDialog(604),
              actions: [
                IconButton(
                  icon: const Icon(Icons.tune_rounded, color: Colors.white),
                  onPressed: () => _showReadingControlsModal(context, settings),
                ),
                IconButton(
                  icon: Icon(
                    isRead ? Icons.bookmark_added : Icons.bookmark_border_rounded,
                    color: isRead ? AppConstants.gold : Colors.white,
                  ),
                  onPressed: () => _showJumpToPageDialog(604),
                ),
              ],
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
