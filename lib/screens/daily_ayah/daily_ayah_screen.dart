import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/constants/constants.dart';
import '../../core/theme/app_theme.dart';

class DailyAyahScreen extends StatelessWidget {
  const DailyAyahScreen({super.key});

  static const List<Map<String, String>> dailyReminders = [
    {
      'type': 'Quran Ayah',
      'arabic': 'إِنَّ مَعَ الْعُسْرِ يُسْرًا',
      'urdu': 'بے شک مشکل کے ساتھ آسانی ہے۔',
      'english': 'Indeed, with hardship comes ease.',
      'reference': 'Surah Ash-Sharh 94:6',
    },
    {
      'type': 'Authentic Hadith',
      'arabic': 'إِنَّمَا الأَعْمَالُ بِالنِّيَّاتِ',
      'urdu': 'اعمال کا دارومدار نیتوں پر ہے۔',
      'english': 'Actions are judged by intentions.',
      'reference': 'Sahih al-Bukhari 1',
    },
    {
      'type': 'Quran Ayah',
      'arabic': 'فَاذْكُرُونِي أَذْكُرْكُمْ وَاشْكُرُوا لِي وَلَا تَكْفُرُونِ',
      'urdu': 'پس تم مجھے یاد کرو، میں تمہیں یاد رکھوں گا اور میرا شکر ادا کرو اور ناشکری نہ کرو۔',
      'english': 'So remember Me; I will remember you. And be grateful to Me and do not deny Me.',
      'reference': 'Surah Al-Baqarah 2:152',
    },
    {
      'type': 'Authentic Hadith',
      'arabic': 'خَيْرُكُمْ مَنْ تَعَلَّمَ الْقُرْآنَ وَعَلَّمَهُ',
      'urdu': 'تم میں سے بہترین وہ ہے جو قرآن سیکھے اور سکھائے۔',
      'english': 'The best among you are those who learn the Quran and teach it.',
      'reference': 'Sahih al-Bukhari 5027',
    },
    {
      'type': 'Quran Ayah',
      'arabic': 'وَمَن يَتَّقِ اللَّهَ يَجْعَل لَّهُ مَخْرَجًا',
      'urdu': 'اور جو اللہ سے ڈرے گا، اللہ اس کے لیے نکلنے کا راستہ بنا دے گا۔',
      'english': 'And whoever fears Allah - He will make for him a way out.',
      'reference': 'Surah At-Talaq 65:2',
    },
  ];

  @override
  Widget build(BuildContext context) {
    // Pick today's reminder based on day of year
    final dayIndex = DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays % dailyReminders.length;
    final todayItem = dailyReminders[dayIndex];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Daily Ayah & Hadith (آیت و حدیث)', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppConstants.primaryGreen,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Header Card
          Container(
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
                Chip(
                  label: Text(
                    todayItem['type'] ?? 'Daily Reminder',
                    style: const TextStyle(color: AppConstants.primaryGreen, fontWeight: FontWeight.bold),
                  ),
                  backgroundColor: Colors.white,
                ),
                const SizedBox(height: 16),
                Directionality(
                  textDirection: TextDirection.rtl,
                  child: Text(
                    todayItem['arabic'] ?? '',
                    style: const TextStyle(
                      fontFamily: AppConstants.uthmaniFont,
                      fontSize: 28,
                      height: 1.8,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  todayItem['urdu'] ?? '',
                  style: const TextStyle(color: Colors.white, fontSize: 16, height: 1.5),
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl,
                ),
                const SizedBox(height: 8),
                Text(
                  todayItem['english'] ?? '',
                  style: const TextStyle(color: Colors.white70, fontSize: 14, fontStyle: FontStyle.italic),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  '— ${todayItem['reference']}',
                  style: const TextStyle(color: AppConstants.gold, fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  Clipboard.setData(ClipboardData(
                    text: '${todayItem['type']}\n\n${todayItem['arabic']}\n\n${todayItem['urdu']}\n\n${todayItem['english']}\n\nRef: ${todayItem['reference']}',
                  ));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Copied to clipboard')),
                  );
                },
                icon: const Icon(Icons.copy),
                label: const Text('Copy Text'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.primaryGreen,
                  foregroundColor: Colors.white,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  Share.share(
                    '${todayItem['type']}\n\n${todayItem['arabic']}\n\n${todayItem['urdu']}\n\n${todayItem['english']}\n\nRef: ${todayItem['reference']}',
                  );
                },
                icon: const Icon(Icons.share),
                label: const Text('Share Reminder'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.gold,
                  foregroundColor: Colors.black87,
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),
          const Text(
            'More Inspirational Verses & Hadiths',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          ...dailyReminders.map((item) {
            return Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.black.withOpacity(0.06)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item['type'] ?? '',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppConstants.primaryGreen, fontSize: 13),
                      ),
                      Text(
                        item['reference'] ?? '',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                  const Divider(height: 16),
                  Directionality(
                    textDirection: TextDirection.rtl,
                    child: Text(
                      item['arabic'] ?? '',
                      style: const TextStyle(
                        fontFamily: AppConstants.uthmaniFont,
                        fontSize: 22,
                        height: 1.8,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item['urdu'] ?? '',
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                    textDirection: TextDirection.rtl,
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
