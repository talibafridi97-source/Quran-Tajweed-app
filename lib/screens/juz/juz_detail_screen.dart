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
      backgroundColor: const Color(0xFFFFF5E1), // Mushaf Beige Background
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
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.brown.shade400, width: 2),
                    color: const Color(0xFFFFF5E1),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Page Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('سُوْرَةُ الْبَقَرَةِ', style: TextStyle(fontSize: 12, color: Colors.brown.shade700, fontFamily: AppConstants.uthmaniFont)),
                            Text('${widget.juzNumber}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                            Text('الْجُزْءُ ${widget.juzNumber}', style: TextStyle(fontSize: 12, color: Colors.brown.shade700, fontFamily: AppConstants.uthmaniFont)),
                          ],
                        ),
                        const Divider(color: Colors.brown, thickness: 1),
                        const SizedBox(height: 10),

                        // Paragraph Layout (Mushaf Style)
                        Directionality(
                          textDirection: TextDirection.rtl,
                          child: Wrap(
                            alignment: WrapAlignment.center,
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
                        
                        const SizedBox(height: 20),
                        const Divider(color: Colors.brown, thickness: 1),
                        const Text('منزل ۱', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        
                        if (settings.showTranslation) ...[
                          const SizedBox(height: 30),
                          const Text('--- Translation ---', style: TextStyle(color: Colors.brown)),
                          const SizedBox(height: 10),
                          ...translations.map((t) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Text(
                              t['text'] ?? '',
                              textAlign: TextAlign.center,
                              textDirection: TextDirection.rtl,
                              style: TextStyle(fontSize: settings.translationFontSize, fontFamily: AppConstants.urduFont, color: Colors.brown.shade900),
                            ),
                          )),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              _buildBottomBar(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, -2))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _barItem(Icons.bookmark_border, 'Bookmark'),
          _barItem(Icons.remove_red_eye_outlined, 'Eye Shield'),
          _barItem(Icons.color_lens_outlined, 'Theme'),
          _barItem(Icons.settings_outlined, 'Settings'),
        ],
      ),
    );
  }

  Widget _barItem(IconData icon, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 22, color: Colors.brown.shade700),
        Text(label, style: const TextStyle(fontSize: 9)),
      ],
    );
  }
}
