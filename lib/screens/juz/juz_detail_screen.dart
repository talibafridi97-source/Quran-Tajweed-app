import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/ayah.dart';
import '../../models/mushaf_16_line_model.dart';
import '../../models/resume_data.dart';
import '../../providers/quran_provider.dart';
import '../../providers/settings_provider.dart';
import '../../core/constants/constants.dart';
import '../../core/widgets/mushaf_page_frame.dart';
import '../../core/widgets/mushaf_16_line_view.dart';
import '../../core/widgets/loading_error_widget.dart';
import '../../services/mushaf_16_line_layout_service.dart';

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

  @override
  void initState() {
    super.initState();
    _buildFuture = _initPages();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<List<Mushaf16LinePage>> _initPages() async {
    final repo = context.read<QuranProvider>().repository;
    final surahs = await repo.getAllSurahs();
    final List<Ayah> allAyahs = await repo.getJuzTajweed(widget.juzNumber);
    
    final pages = _layoutService.buildAllPages(surahs: surahs, allAyahs: allAyahs);
    final startPage = _layoutService.getJuzStartPage(widget.juzNumber);
    _pageController = PageController(initialPage: startPage - 1);
    
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
          return const Scaffold(body: LoadingErrorWidget(isLoading: true, child: SizedBox.shrink()));
        }
        
        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: Text('Para ${widget.juzNumber}')),
            body: LoadingErrorWidget(
              isLoading: false,
              errorMessage: snapshot.error?.toString() ?? 'No data found',
              onRetry: () => setState(() { _buildFuture = _initPages(); }),
              child: const SizedBox.shrink(),
            ),
          );
        }

        final pages = snapshot.data!;

        return PageView.builder(
          controller: _pageController,
          itemCount: pages.length,
          reverse: true,
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
              totalPages: 604, // Standard Quran total pages
              surahNameArabic: page.surahName,
              juzNameArabic: 'الجزء ${page.juzNumber}',
              isRead: isRead,
              showControls: _showControls,
              onTap: () => setState(() => _showControls = !_showControls),
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
