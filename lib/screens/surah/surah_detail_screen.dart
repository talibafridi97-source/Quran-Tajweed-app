import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/surah.dart';
import '../../models/ayah.dart';
import '../../providers/quran_provider.dart';
import '../../providers/settings_provider.dart';
import '../../core/constants/constants.dart';
import '../../core/widgets/tajweed_text.dart';
import '../../core/widgets/loading_error_widget.dart';
import '../../core/widgets/quran_audio_player_widget.dart';
import 'package:google_fonts/google_fonts.dart';

class SurahDetailScreen extends StatefulWidget {
  final Surah surah;
  const SurahDetailScreen({super.key, required this.surah});

  @override
  State<SurahDetailScreen> createState() => _SurahDetailScreenState();
}

class _SurahDetailScreenState extends State<SurahDetailScreen> {
  late Future<List<Ayah>> _ayahsFuture;
  bool _showAudioPlayer = false;

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

    return Scaffold(
      backgroundColor: const Color(0xFFFCF9F2),
      appBar: AppBar(
        title: Text(widget.surah.englishName),
        actions: [
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Surah ${widget.surah.englishName} bookmarked')),
              );
            },
            icon: const Icon(Icons.bookmark_add_outlined),
          ),
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
            onRetry: () => setState(() => _loadSurahData()),
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    children: [
                      _buildSurahHeader(),
                      const SizedBox(height: 16),
                      if (_showAudioPlayer) ...[
                        QuranAudioPlayerWidget(
                          surahNumber: widget.surah.number,
                          surahName: widget.surah.englishName,
                        ),
                        const SizedBox(height: 16),
                      ],
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(32),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20)
                          ],
                        ),
                        child: TajweedText(
                          ayahs: ayahs,
                          fontSize: settings.arabicFontSize,
                          fontFamily: AppConstants.uthmaniFont,
                          showTajweed: settings.showTajweed,
                          textAlign: TextAlign.justify,
                        ),
                      ),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
                _buildModernActionButtons(),
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
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppConstants.primaryGreen, Color(0xFF007A72)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: AppConstants.primaryGreen.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            widget.surah.name,
            style: const TextStyle(fontFamily: AppConstants.uthmaniFont, fontSize: 38, color: Colors.white),
          ),
          const SizedBox(height: 12),
          Text(
            '${widget.surah.englishNameTranslation} • ${widget.surah.numberOfAyahs} Ayahs',
            style: GoogleFonts.plusJakartaSans(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 24),
          const Divider(color: Colors.white24, height: 1),
          const SizedBox(height: 24),
          const Text(
            'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
            style: TextStyle(fontFamily: AppConstants.uthmaniFont, fontSize: 26, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildModernActionButtons() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5))
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _showAudioPlayer = !_showAudioPlayer;
              });
            },
            child: _actionItem(Icons.play_circle_fill, _showAudioPlayer ? 'Hide Audio' : 'Listen', AppConstants.softBlue),
          ),
          InkWell(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Arabic Only view active')),
              );
            },
            child: _actionItem(Icons.translate_rounded, 'Urdu', AppConstants.softPurple),
          ),
          InkWell(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Sharing Surah ${widget.surah.englishName}')),
              );
            },
            child: _actionItem(Icons.share_rounded, 'Share', AppConstants.vibrantOrange),
          ),
          InkWell(
            onTap: () {
              Navigator.pushNamed(context, '/settings');
            },
            child: _actionItem(Icons.settings_suggest_rounded, 'Config', AppConstants.primaryGreen),
          ),
        ],
      ),
    );
  }

  Widget _actionItem(IconData icon, String label, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 6),
        Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.grey[600])),
      ],
    );
  }
}
