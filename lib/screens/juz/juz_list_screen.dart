import 'package:flutter/material.dart';
import '../../core/constants/constants.dart';
import 'juz_detail_screen.dart';

class JuzListScreen extends StatelessWidget {
  const JuzListScreen({super.key});

  static const List<Map<String, String>> juzData = [
    {'en': 'Alif Lam Meem', 'ar': 'الٓمّٓ', 'page': '2'},
    {'en': 'Sayaqool', 'ar': 'سَيَقُوْلُ', 'page': '22'},
    {'en': 'Tilkal Rusull', 'ar': 'تِلْكَ الرُّسُلُ', 'page': '42'},
    {'en': 'Lan Tana Loo', 'ar': 'لَنْ تَنَالُوْا', 'page': '62'},
    {'en': 'Wal Mohsanat', 'ar': 'وَالْمُحْصَنٰتُ', 'page': '82'},
    {'en': 'La Yuhibbullah', 'ar': 'لَا يُحِبُّ اللّٰهُ', 'page': '102'},
    {'en': 'Wa Iza Samiu', 'ar': 'وَإِذَا سَمِعُوْا', 'page': '122'},
    {'en': 'Wa Lau Annana', 'ar': 'وَلَوْ أَنَّنَا', 'page': '142'},
    {'en': 'Qal Al-Mala', 'ar': 'قَالَ الْمَلَاُ', 'page': '162'},
    {'en': 'Wa\'lamu', 'ar': 'وَاعْلَمُوْا', 'page': '182'},
    {'en': 'Ya\'tazirun', 'ar': 'يَعْتَذِرُوْنَ', 'page': '202'},
    {'en': 'Wa Ma Min Dabbah', 'ar': 'وَمَا مِنْ دَابَّةٍ', 'page': '222'},
    {'en': 'Wa Ma Ubarriu', 'ar': 'وَمَا أُبَرِّئُ', 'page': '242'},
    {'en': 'Rubama', 'ar': 'رُبَمَا', 'page': '262'},
    {'en': 'Subhanallazi', 'ar': 'سُبْحٰنَ الَّذِيْ', 'page': '282'},
    {'en': 'Qal Alam', 'ar': 'قَالَ أَلَمْ', 'page': '302'},
    {'en': 'Aqtaraba', 'ar': 'اقْتَرَبَ', 'page': '322'},
    {'en': 'Qad Aflaha', 'ar': 'قَدْ أَفْلَحَ', 'page': '342'},
    {'en': 'Wa Qallazina', 'ar': 'وَقَالَ الَّذِيْنَ', 'page': '362'},
    {'en': 'Aman Khalaq', 'ar': 'أَمَّنْ خَلَقَ', 'page': '382'},
    {'en': 'Utlu Ma Uhiya', 'ar': 'اتْلُ مَا أُوْحِيَ', 'page': '402'},
    {'en': 'Wa Man Yaqnut', 'ar': 'وَمَنْ يَّقْنُتْ', 'page': '422'},
    {'en': 'Wa Maliya', 'ar': 'وَمَا لِيَ', 'page': '442'},
    {'en': 'Faman Azlam', 'ar': 'فَمَنْ أَظْلَمُ', 'page': '462'},
    {'en': 'Ilayhi Yuraddu', 'ar': 'إِلَيْهِ يُرَدُّ', 'page': '482'},
    {'en': 'Ha Meem', 'ar': 'حٰمٓ', 'page': '502'},
    {'en': 'Qala Fama Khatbukum', 'ar': 'قَالَ فَمَا خَطْبُكُمْ', 'page': '522'},
    {'en': 'Qad Sami Allah', 'ar': 'قَدْ سَمِعَ اللّٰهُ', 'page': '542'},
    {'en': 'Tabarakallazi', 'ar': 'تَبٰرَكَ الَّذِيْ', 'page': '562'},
    {'en': 'Amma Yatasa\'alun', 'ar': 'عَمَّ يَتَسَاءَلُوْنَ', 'page': '582'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Juz Index'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: juzData.length,
        itemBuilder: (context, index) {
          final juz = juzData[index];
          final juzNumber = index + 1;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Card(
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => JuzDetailScreen(juzNumber: juzNumber),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(24),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppConstants.accentGreen.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            '$juzNumber',
                            style: const TextStyle(
                              color: AppConstants.accentGreen,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              juz['en']!,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Starts at Page ${juz['page']}',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        juz['ar']!,
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
              ),
            ),
          );
        },
      ),
    );
  }
}
