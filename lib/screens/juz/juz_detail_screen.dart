import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/quran_provider.dart';
import '../../providers/settings_provider.dart';
import '../../core/constants/constants.dart';
import '../../core/widgets/tajweed_text.dart';

class JuzDetailScreen extends StatefulWidget {
  final int juzNumber;
  const JuzDetailScreen({super.key, required this.juzNumber});

  @override
  State<JuzDetailScreen> createState() => _JuzDetailScreenState();
}

class _JuzDetailScreenState extends State<JuzDetailScreen> {
  late Future<List<dynamic>> _dataFuture;

  @override
  void initState() {
    super.initState();
    final repository = context.read<QuranProvider>().repository;
    _dataFuture = Future.wait([
      repository.getJuzTajweed(widget.juzNumber),
      repository.getJuzTranslation(widget.juzNumber),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFFCF9F2), // Slightly warmer modern mushaf background
      appBar: AppBar(
        title: Text('Juz ${widget.juzNumber}'),
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
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Column(
                    children: [
                      _buildHeaderFrame(),
                      const SizedBox(height: 24),
                      Directionality(
                        textDirection: TextDirection.rtl,
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 4,
                          runSpacing: 8,
                          children: List.generate(tajweedVerses.length, (index) {
                            final verse = tajweedVerses[index];
                            return TajweedText(
                              rawText: '${verse['text']!} ',
                              fontSize: settings.arabicFontSize,
                              fontFamily: AppConstants.uthmaniFont,
                              ayahNumber: index + 1,
                            );
                          }),
                        ),
                      ),
                      if (settings.showTranslation) _buildModernTranslations(translations, settings),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
              _buildModernBottomBar(context),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeaderFrame() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppConstants.gold.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)
        ],
      ),
      child: const Text(
        'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
        style: TextStyle(fontFamily: AppConstants.uthmaniFont, fontSize: 22),
      ),
    );
  }

  Widget _buildModernTranslations(List<Map<String, String>> translations, SettingsProvider settings) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 30),
          child: Row(
            children: [
              Expanded(child: Divider()),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text('Translation', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
              Expanded(child: Divider()),
            ],
          ),
        ),
        ...translations.map((t) => Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            t['text'] ?? '',
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
            style: TextStyle(
              fontSize: settings.translationFontSize,
              fontFamily: AppConstants.urduFont,
              color: Colors.black87,
              height: 1.5,
            ),
          ),
        )),
      ],
    );
  }

  Widget _buildModernBottomBar(BuildContext context) {
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
          _modernBarItem(Icons.bookmark_add_outlined, 'Save'),
          _modernBarItem(Icons.visibility_outlined, 'View'),
          _modernBarItem(Icons.palette_outlined, 'Theme'),
          _modernBarItem(Icons.settings_outlined, 'Settings'),
        ],
      ),
    );
  }

  Widget _modernBarItem(IconData icon, String label) {
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
