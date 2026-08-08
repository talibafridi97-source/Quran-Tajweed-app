import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/surah.dart';
import '../../providers/quran_provider.dart';
import '../../providers/settings_provider.dart';
import '../../core/constants/constants.dart';
import '../../core/widgets/tajweed_text.dart';

class SurahDetailScreen extends StatefulWidget {
  final Surah surah;
  const SurahDetailScreen({super.key, required this.surah});

  @override
  State<SurahDetailScreen> createState() => _SurahDetailScreenState();
}

class _SurahDetailScreenState extends State<SurahDetailScreen> {
  late Future<List<dynamic>> _dataFuture;

  @override
  void initState() {
    super.initState();
    final repository = context.read<QuranProvider>().repository;
    _dataFuture = Future.wait([
      repository.getSurahTajweed(widget.surah.number),
      repository.getSurahTranslation(widget.surah.number),
    ]);
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
            icon: const Icon(Icons.info_outline),
            onPressed: () {},
          )
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _dataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final tajweedVerses = snapshot.data![0] as List<Map<String, String>>;
          final translations = snapshot.data![1] as List<Map<String, String>>;

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: Column(
                    children: [
                      _buildSurahHeader(),
                      const SizedBox(height: 30),
                      Directionality(
                        textDirection: TextDirection.rtl,
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 4,
                          runSpacing: 12,
                          children: List.generate(tajweedVerses.length, (index) {
                            return TajweedText(
                              rawText: '${tajweedVerses[index]['text']!} ',
                              fontSize: settings.arabicFontSize,
                              fontFamily: AppConstants.uthmaniFont,
                              ayahNumber: index + 1,
                            );
                          }),
                        ),
                      ),
                      if (settings.showTranslation) _buildTranslationsList(translations, settings),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
              _buildModernBottomBar(),
            ],
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
      ),
      child: Column(
        children: [
          Text(
            widget.surah.name,
            style: const TextStyle(fontFamily: AppConstants.uthmaniFont, fontSize: 36, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            '${widget.surah.englishNameTranslation} • ${widget.surah.numberOfAyahs} Ayahs',
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white24),
          const SizedBox(height: 16),
          const Text(
            'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
            style: TextStyle(fontFamily: AppConstants.uthmaniFont, fontSize: 24, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildTranslationsList(List<Map<String, String>> translations, SettingsProvider settings) {
    return Column(
      children: [
        const SizedBox(height: 40),
        ...translations.map((t) => Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
          ),
          child: Text(
            t['text'] ?? '',
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
            style: TextStyle(
              fontSize: settings.translationFontSize,
              fontFamily: AppConstants.urduFont,
              color: Colors.black87,
              height: 1.6,
            ),
          ),
        )),
      ],
    );
  }

  Widget _buildModernBottomBar() {
    return Container(
      padding: const EdgeInsets.only(top: 12, bottom: 24),
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
          _barItem(Icons.bookmark_add_outlined, 'Save'),
          _barItem(Icons.play_circle_outline, 'Audio'),
          _barItem(Icons.share_outlined, 'Share'),
          _barItem(Icons.settings_outlined, 'Settings'),
        ],
      ),
    );
  }

  Widget _barItem(IconData icon, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 24, color: AppConstants.primaryGreen),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
      ],
    );
  }
}
