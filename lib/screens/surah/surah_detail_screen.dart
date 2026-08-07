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

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFFFF5E1),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Al-Quran',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _dataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppConstants.primaryGreen));
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
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Column(
                    children: [
                      // Surah Name Header Simulation
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.brown.shade300, width: 1),
                        ),
                        child: Text(
                          widget.surah.name,
                          style: const TextStyle(
                            fontFamily: AppConstants.uthmaniFont,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      // Bismillah
                      if (widget.surah.number != 1 && widget.surah.number != 9)
                        const Padding(
                          padding: EdgeInsets.only(bottom: 20),
                          child: Text(
                            'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: AppConstants.uthmaniFont,
                              fontSize: 24,
                            ),
                          ),
                        ),

                      // Ayahs in a centered paragraph-like style
                      Wrap(
                        alignment: WrapAlignment.center,
                        children: List.generate(tajweedVerses.length, (index) {
                          final verse = tajweedVerses[index];
                          final ayahNumber = index + 1;
                          
                          return Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: TajweedText(
                              rawText: '${verse['text']!} ',
                              fontSize: settings.arabicFontSize,
                              fontFamily: AppConstants.uthmaniFont,
                              textAlign: TextAlign.center,
                            ),
                          );
                        }),
                      ),
                      
                      const SizedBox(height: 40),
                      
                      // Translation Section (if enabled)
                      if (settings.showTranslation)
                        Column(
                          children: List.generate(translations.length, (index) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: Text(
                                translations[index]['text'] ?? '',
                                textAlign: TextAlign.center,
                                textDirection: TextDirection.rtl,
                                style: TextStyle(
                                  fontSize: settings.translationFontSize,
                                  fontFamily: AppConstants.urduFont,
                                  color: Colors.brown.shade800,
                                ),
                              ),
                            );
                          }),
                        ),
                    ],
                  ),
                ),
              ),
              
              // Bottom Navigation Bar
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildBottomItem(Icons.bookmark_border, 'Bookmark'),
                    _buildBottomItem(Icons.remove_red_eye_outlined, 'Eye Shield'),
                    _buildBottomItem(Icons.color_lens_outlined, 'Theme'),
                    _buildBottomItem(Icons.settings_outlined, 'Settings'),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBottomItem(IconData icon, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 24, color: Colors.brown.shade700),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 10, color: Colors.brown.shade700),
        ),
      ],
    );
  }
}
