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
    {'en': 'Wa Ma Ubarriu', 'ar': 'وَمَا أُبَرِّئُ', 'style': '242'},
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
      backgroundColor: const Color(0xFF002121),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Juz Index',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Stack(
        children: [
          // Decorative Border
          Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFECC146), width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Container(
              margin: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFECC146), width: 1),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          
          ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            itemCount: juzData.length,
            itemBuilder: (context, index) {
              final juz = juzData[index];
              final juzNumber = index + 1;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => JuzDetailScreen(juzNumber: juzNumber),
                      ),
                    );
                  },
                  child: Container(
                    height: 100,
                    decoration: BoxDecoration(
                      color: const Color(0xFFECC146),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Stack(
                      children: [
                        // Juz Number
                        Positioned(
                          left: 12,
                          top: 0,
                          bottom: 0,
                          child: Center(
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.black54, width: 1),
                              ),
                              child: Center(
                                child: Text(
                                  '$juzNumber',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        
                        // English Name and Page
                        Positioned(
                          left: 65,
                          top: 20,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                juz['en']!,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Page: ${juz['page'] ?? index * 20 + 2}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // Arabic Name
                        Positioned(
                          right: 16,
                          top: 0,
                          bottom: 0,
                          child: Center(
                            child: Text(
                              juz['ar']!,
                              style: const TextStyle(
                                fontFamily: AppConstants.uthmaniFont,
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
