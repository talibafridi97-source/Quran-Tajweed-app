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

  @override
  void initState() {
    super.initState();
    _loadJuzData();
  }

  void _loadJuzData() {
    final repository = context.read<QuranProvider>().repository;
    _juzFuture = repository.getJuzTajweed(widget.juzNumber);
  }

  // Group ayahs by Surah
  Map<int, List<Ayah>> _groupAyahsBySurah(List<Ayah> ayahs) {
    final Map<int, List<Ayah>> grouped = {};
    for (final ayah in ayahs) {
      final sNum = ayah.surahNumber ?? 0;
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
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_outline),
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
                SnackBar(content: Text('Saved Para ${widget.juzNumber} as last read point')),
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
                  const Icon(Icons.menu_book, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'No Quran content found for Para ${widget.juzNumber}.',
                    style: const TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _loadJuzData();
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConstants.primaryGreen,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Reload'),
                  ),
                ],
              ),
            );
          }

          final groupedSurahs = _groupAyahsBySurah(ayahs);

          return LoadingErrorWidget(
            isLoading: isLoading,
            errorMessage: hasError ? snapshot.error.toString() : null,
            onRetry: () {
              setState(() {
                _loadJuzData();
              });
            },
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              children: [
                _buildJuzHeader(juzMeta),
                const SizedBox(height: 20),
                ...groupedSurahs.entries.map((entry) {
                  final surahAyahs = entry.value;
                  final firstAyah = surahAyahs.first;
                  final surahName = firstAyah.surahName ?? 'سورة';
                  final surahEngName = firstAyah.surahEnglishName ?? '';
                  final sNum = entry.key;

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
                      children: [
                        // Surah Section Banner inside Juz
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: AppConstants.primaryGreen.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppConstants.primaryGreen.withOpacity(0.2)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                surahEngName.isNotEmpty ? surahEngName : 'Surah $sNum',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: AppConstants.primaryGreen,
                                ),
                              ),
                              Text(
                                surahName,
                                style: const TextStyle(
                                  fontFamily: AppConstants.uthmaniFont,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: AppConstants.primaryGreen,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Bismillah banner if starting at Ayah 1
                        if (firstAyah.numberInSurah == 1 && sNum != 1 && sNum != 9) ...[
                          const SizedBox(height: 16),
                          const Text(
                            'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                            style: TextStyle(
                              fontFamily: AppConstants.uthmaniFont,
                              fontSize: 24,
                              color: AppConstants.primaryGreen,
                            ),
                          ),
                        ],

                        const SizedBox(height: 16),

                        // Arabic Tajweed Ayahs
                        Directionality(
                          textDirection: TextDirection.rtl,
                          child: Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 4,
                            runSpacing: 12,
                            children: surahAyahs.map((ayah) {
                              return TajweedText(
                                rawText: '${ayah.text} ',
                                fontSize: settings.arabicFontSize,
                                fontFamily: AppConstants.uthmaniFont,
                                ayahNumber: ayah.numberInSurah,
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 30),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildJuzHeader(JuzModel juz) {
    return Container(
      width: double.infinity,
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
            'Para ${juz.number} • ${juz.nameEnglish} • Starts at Page ${juz.startPage}',
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
