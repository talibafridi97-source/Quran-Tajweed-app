import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
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

  void _copyAyah(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Ayah copied to clipboard')),
    );
  }

  void _shareAyah(String text, String translation) {
    Share.share('$text\n\n$translation\n\n(Surah ${widget.surah.englishName})');
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            Text(widget.surah.englishName),
            Text(
              widget.surah.name,
              style: const TextStyle(fontSize: 14, fontFamily: AppConstants.uthmaniFont),
            ),
          ],
        ),
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

          return ListView.builder(
            itemCount: tajweedVerses.length,
            padding: const EdgeInsets.symmetric(vertical: 16),
            itemBuilder: (context, index) {
              final verse = tajweedVerses[index];
              final translation = translations[index]['text'] ?? '';
              final ayahNumber = index + 1;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Card(
                  elevation: 0,
                  color: Theme.of(context).cardColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey.withAlpha(50)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Header with actions
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: AppConstants.primaryGreen.withAlpha(30),
                              child: Text(
                                '$ayahNumber',
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.copy, size: 20),
                                  onPressed: () => _copyAyah(verse['text']!),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.share, size: 20),
                                  onPressed: () => _shareAyah(verse['text']!, translation),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.bookmark_border, size: 20),
                                  onPressed: () {},
                                ),
                                IconButton(
                                  icon: const Icon(Icons.play_circle_outline, size: 20),
                                  onPressed: () {},
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Arabic Tajweed Text
                        TajweedText(
                          rawText: verse['text']!,
                          fontSize: settings.arabicFontSize,
                          fontFamily: AppConstants.uthmaniFont,
                          ayahNumber: ayahNumber,
                        ),
                        if (settings.showTranslation) ...[
                          const SizedBox(height: 16),
                          // Translation text
                          Text(
                            translation,
                            textDirection: TextDirection.rtl,
                            style: TextStyle(
                              fontSize: settings.translationFontSize,
                              fontFamily: AppConstants.urduFont,
                              color: Colors.grey[700],
                              height: 1.6,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
