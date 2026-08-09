import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/surah.dart';
import '../../models/ayah.dart';
import '../../models/resume_data.dart';
import '../../providers/quran_provider.dart';
import '../../providers/settings_provider.dart';
import '../../core/constants/constants.dart';
import '../../core/widgets/tajweed_text.dart';
import '../../core/widgets/loading_error_widget.dart';

class SurahDetailScreen extends StatefulWidget {
  final Surah surah;
  const SurahDetailScreen({super.key, required this.surah});

  @override
  State<SurahDetailScreen> createState() => _SurahDetailScreenState();
}

class _SurahDetailScreenState extends State<SurahDetailScreen> {
  late Future<List<Ayah>> _ayahsFuture;

  @override
  void initState() {
    super.initState();
    _loadSurahData();
  }

  void _loadSurahData() {
    final repository = context.read<QuranProvider>().repository;
    _ayahsFuture = repository.getSurahTajweed(widget.surah.number);
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final quranProvider = context.read<QuranProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFFAF8F5), // Clean Mushaf paper background
      appBar: AppBar(
        title: Text(widget.surah.englishName),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_outline),
            onPressed: () {
              quranProvider.saveResume(ResumeData(
                surahName: widget.surah.name,
                surahNumber: widget.surah.number,
                ayahNumber: 1,
                page: 1,
                juz: 1,
                lastRead: DateTime.now(),
              ));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Saved ${widget.surah.englishName} as last read point')),
              );
            },
          )
        ],
      ),
      body: FutureBuilder<List<Ayah>>(
        future: _ayahsFuture,
        builder: (context, snapshot) {
          final isLoading = snapshot.connectionState == ConnectionState.waiting;
          final hasError = snapshot.hasError;
          final ayahs = snapshot.data ?? [];

          return LoadingErrorWidget(
            isLoading: isLoading,
            errorMessage: hasError ? snapshot.error.toString() : null,
            onRetry: () {
              setState(() {
                _loadSurahData();
              });
            },
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              children: [
                _buildSurahHeader(),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.black.withOpacity(0.06)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: Directionality(
                    textDirection: TextDirection.rtl,
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 4,
                      runSpacing: 12,
                      children: List.generate(ayahs.length, (index) {
                        final ayah = ayahs[index];
                        return TajweedText(
                          rawText: '${ayah.text} ',
                          fontSize: settings.arabicFontSize,
                          fontFamily: AppConstants.uthmaniFont,
                          ayahNumber: ayah.numberInSurah,
                        );
                      }),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSurahHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppConstants.primaryGreen, Color(0xFF006D6D)],
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
        children: [
          Text(
            widget.surah.name,
            style: const TextStyle(
              fontFamily: AppConstants.uthmaniFont,
              fontSize: 36,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${widget.surah.englishNameTranslation} • ${widget.surah.numberOfAyahs} Ayahs • ${widget.surah.revelationType}',
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
          if (widget.surah.number != 1 && widget.surah.number != 9) ...[
            const SizedBox(height: 16),
            const Divider(color: Colors.white24),
            const SizedBox(height: 16),
            const Text(
              'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
              style: TextStyle(
                fontFamily: AppConstants.uthmaniFont,
                fontSize: 26,
                color: Colors.white,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
