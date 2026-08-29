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

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialPage.clamp(1, 811);
    _pageController = PageController(initialPage: _currentPage - 1);
    _buildFuture = _initPages();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
  }

  Future<List<Mushaf16LinePage>> _initPages() async {
    if (_layoutService.isReady) {
      final cachedPages = _layoutService.buildAllPages(surahs: [], allAyahs: []);
      if (cachedPages.isNotEmpty) {
        return cachedPages;
      }
    }

    final repo = context.read<QuranProvider>().repository;
    final surahs = await repo.getAllSurahs();
    final allAyahs = await repo.ensureAllAyahsLoaded();

    return _layoutService.buildAllPages(surahs: surahs, allAyahs: allAyahs);
  }

  void _onPageChanged(int index) {
    final newPageNumber = index + 1;
    setState(() {
      _currentPage = newPageNumber;
    });

    final page = _layoutService.getPage(newPageNumber);
    if (page != null) {
      final firstAyahNum = page.lines
              .firstWhere(
                (l) => l.ayahNumbers.isNotEmpty,
                orElse: () => page.lines.first,
              )
              .ayahNumbers
              .firstOrNull ??
          1;

      context.read<QuranProvider>().saveResume(ResumeData(
            surahName: page.surahName,
            surahNumber: page.surahNumber,
            ayahNumber: firstAyahNum,
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
              final page = int.tryParse(textController.text);
              if (page != null && page >= 1 && page <= totalPages) {
                _pageController.animateToPage(
                  page - 1,
                  duration: const Duration(milliseconds: 250),
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
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 20,
                  offset: const Offset(0, -4),
                ),
              ],
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

                // Font Family Selector
                const Text('Arabic Font Style', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    ChoiceChip(
                      label: const Text('Noto Naskh (Default)'),
                      selected: settings.arabicFontFamily == 'NotoNaskhArabic' || settings.arabicFontFamily.isEmpty,
                      selectedColor: AppConstants.primaryGreen,
                      labelStyle: TextStyle(
                        color: (settings.arabicFontFamily == 'NotoNaskhArabic' || settings.arabicFontFamily.isEmpty)
                            ? Colors.white
                            : null,
                      ),
                      onSelected: (sel) {
                        if (sel) {
                          settings.setArabicFontFamily('NotoNaskhArabic');
                          setModalState(() {});
                        }
                      },
                    ),
                    ChoiceChip(
                      label: const Text('Amiri Quran'),
                      selected: settings.arabicFontFamily == 'Amiri' || settings.arabicFontFamily == 'QuranAmiri',
                      selectedColor: AppConstants.primaryGreen,
                      labelStyle: TextStyle(
                        color: (settings.arabicFontFamily == 'Amiri' || settings.arabicFontFamily == 'QuranAmiri')
                            ? Colors.white
                            : null,
                      ),
                      onSelected: (sel) {
                        if (sel) {
                          settings.setArabicFontFamily('Amiri');
                          setModalState(() {});
                        }
                      },
                    ),
                    ChoiceChip(
                      label: const Text('Uthmani Classic'),
                      selected: settings.arabicFontFamily == 'Uthmani',
                      selectedColor: AppConstants.primaryGreen,
                      labelStyle: TextStyle(
                        color: settings.arabicFontFamily == 'Uthmani' ? Colors.white : null,
                      ),
                      onSelected: (sel) {
                        if (sel) {
                          settings.setArabicFontFamily('Uthmani');
                          setModalState(() {});
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Tajweed Toggle
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Interactive Tajweed Coloring', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text('Color-coded rules for Qalqalah, Ghunnah, Idgham, Madd, etc.'),
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
        final isLoading = snapshot.connectionState == ConnectionState.waiting;
        final hasError = snapshot.hasError;
        final pages = snapshot.data ?? [];
        final totalPages = pages.isNotEmpty ? pages.length : _layoutService.totalPages;

        if (isLoading || hasError || pages.isEmpty) {
          return Scaffold(
            backgroundColor: AppConstants.deepEmerald,
            appBar: AppBar(
              backgroundColor: AppConstants.primaryGreen,
              leading: const BackButton(color: Colors.white),
              title: const Text('16-Line Quran Mushaf', style: TextStyle(color: Colors.white)),
            ),
            body: LoadingErrorWidget(
              isLoading: isLoading,
              errorMessage: hasError ? snapshot.error.toString() : null,
              onRetry: () {
                setState(() {
                  _buildFuture = _initPages();
                });
              },
              child: const SizedBox.shrink(),
            ),
          );
        }

        return PageView.builder(
          controller: _pageController,
          onPageChanged: _onPageChanged,
          physics: const BouncingScrollPhysics(),
          reverse: true, // Authentic Right-to-Left page flipping
          itemCount: pages.length,
          itemBuilder: (context, index) {
            final page = pages[index];
            final isRead = quranProvider.getPageReadStatus(page.pageNumber);

            return MushafPageFrame(
              pageNumber: page.pageNumber,
              totalPages: totalPages,
              surahNameArabic: page.surahName,
              juzNameArabic: 'الجزء ${page.juzNumber}',
              isRead: isRead,
              showControls: _showControls,
              onTap: _toggleControls,
              onReadChanged: (val) {
                quranProvider.togglePageReadStatus(page.pageNumber);
              },
              onBookmarkPressed: () => _showJumpToPageDialog(totalPages),
              actions: [
                IconButton(
                  icon: const Icon(Icons.tune_rounded, color: Colors.white),
                  tooltip: 'Reading Controls',
                  onPressed: () => _showReadingControlsModal(context, settings),
                ),
                IconButton(
                  icon: Icon(
                    isRead ? Icons.bookmark_added : Icons.bookmark_border_rounded,
                    color: isRead ? AppConstants.gold : Colors.white,
                  ),
                  onPressed: () => _showJumpToPageDialog(totalPages),
                  tooltip: 'Jump to Page / Bookmark',
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
