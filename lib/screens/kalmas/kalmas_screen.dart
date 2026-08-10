import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/constants/constants.dart';
import '../../models/kalma_model.dart';

class KalmasScreen extends StatelessWidget {
  const KalmasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF8F5),
      appBar: AppBar(
        title: const Text('6 Kalmas', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppConstants.primaryGreen,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: KalmaModel.allKalmas.length,
        itemBuilder: (context, index) {
          final kalma = KalmaModel.allKalmas[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppConstants.primaryGreen.withOpacity(0.1)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppConstants.primaryGreen,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        kalma.titleEnglish,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        kalma.titleUrdu,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Arabic Text
                Directionality(
                  textDirection: TextDirection.rtl,
                  child: Text(
                    kalma.arabicText,
                    style: const TextStyle(
                      fontFamily: AppConstants.uthmaniFont,
                      fontSize: 26,
                      height: 2.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),

                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 12),

                // Urdu Meaning
                const Text(
                  'اردو ترجمہ:',
                  style: TextStyle(fontWeight: FontWeight.bold, color: AppConstants.primaryGreen, fontSize: 13),
                  textDirection: TextDirection.rtl,
                ),
                const SizedBox(height: 4),
                Text(
                  kalma.urduMeaning,
                  style: const TextStyle(fontSize: 15, color: Colors.black87, height: 1.6),
                  textDirection: TextDirection.rtl,
                ),

                const SizedBox(height: 12),

                // English Meaning
                const Text(
                  'English Translation:',
                  style: TextStyle(fontWeight: FontWeight.bold, color: AppConstants.primaryGreen, fontSize: 13),
                ),
                const SizedBox(height: 4),
                Text(
                  kalma.englishMeaning,
                  style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.5),
                ),

                const SizedBox(height: 16),

                // Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.copy, color: AppConstants.primaryGreen),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(
                          text: '${kalma.titleEnglish} (${kalma.titleUrdu})\n\n${kalma.arabicText}\n\n${kalma.urduMeaning}',
                        ));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Kalma copied to clipboard')),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.share, color: AppConstants.primaryGreen),
                      onPressed: () {
                        Share.share(
                          '${kalma.titleEnglish} (${kalma.titleUrdu})\n\n${kalma.arabicText}\n\n${kalma.urduMeaning}\n\n${kalma.englishMeaning}',
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
