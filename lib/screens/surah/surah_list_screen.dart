import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/constants.dart';
import '../../providers/quran_provider.dart';
import '../../core/widgets/loading_error_widget.dart';
import '../../core/widgets/surah_card_tile.dart';
import '../../services/audio_manager_service.dart';
import 'surah_detail_screen.dart';

class SurahListScreen extends StatefulWidget {
  const SurahListScreen({super.key});

  @override
  State<SurahListScreen> createState() => _SurahListScreenState();
}

class _SurahListScreenState extends State<SurahListScreen> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<QuranProvider>();
      if (provider.surahs.isEmpty) {
        provider.fetchSurahs();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final quranProvider = context.watch<QuranProvider>();
    final audioManager = context.watch<AudioManagerService>();
    final filteredSurahs = quranProvider.surahs.where((s) {
      final q = _searchQuery.toLowerCase();
      return s.englishName.toLowerCase().contains(q) ||
          s.name.contains(q) ||
          s.number.toString() == q;
    }).toList();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        children: [
          _buildSearchField(isDark),
          Expanded(
            child: LoadingErrorWidget(
              isLoading: quranProvider.isLoading,
              errorMessage: quranProvider.errorMessage,
              onRetry: () => quranProvider.fetchSurahs(),
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                physics: const BouncingScrollPhysics(),
                itemCount: filteredSurahs.length,
                itemBuilder: (context, index) {
                  final surah = filteredSurahs[index];
                  final isPlaying = audioManager.currentChannel == AudioChannel.quran &&
                      audioManager.currentSurahNumber == surah.number &&
                      audioManager.isPlaying;

                  return SurahCardTile(
                    surah: surah,
                    isPlaying: isPlaying,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SurahDetailScreen(surah: surah),
                        ),
                      );
                    },
                    onPlayTap: () {
                      if (isPlaying) {
                        audioManager.pause();
                      } else {
                        audioManager.playSurah(
                          surahNumber: surah.number,
                          surahName: surah.englishName,
                          totalAyahs: surah.numberOfAyahs,
                        );
                      }
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
      child: TextField(
        onChanged: (val) => setState(() => _searchQuery = val),
        decoration: InputDecoration(
          hintText: 'Search 114 Surahs (Name, Number)...',
          prefixIcon: const Icon(Icons.search_rounded, size: 22),
          filled: true,
          fillColor: isDark
              ? AppConstants.surfaceDark
              : Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : AppConstants.primaryGreen.withValues(alpha: 0.12),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: AppConstants.gold, width: 1.5),
          ),
        ),
      ),
    );
  }
}
