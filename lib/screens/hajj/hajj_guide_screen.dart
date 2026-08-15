import 'package:flutter/material.dart';
import '../../core/constants/constants.dart';

class HajjGuideScreen extends StatelessWidget {
  const HajjGuideScreen({super.key});

  static const List<Map<String, String>> hajjSteps = [
    {
      'step': '1. Ihram & Intention (احرام اور نیت)',
      'desc': 'Enter state of Ihram before crossing the Miqat. Perform Ghusl, put on two white unstitched sheets, and make Niyyah for Umrah/Hajj.',
      'duaArabic': 'لَبَّيْكَ اللَّهُمَّ عُمْرَةً / لَبَّيْكَ اللَّهُمَّ حَجًّا',
      'duaUrdu': 'اے اللہ! میں عمرہ/حج کی نیت کرتا ہوں، میں حاضر ہوں۔',
    },
    {
      'step': '2. Tawaf al-Qudum (طواف قدوم / طواف عمرہ)',
      'desc': 'Perform 7 circuits counter-clockwise around the Holy Kaaba starting from Hajar al-Aswad (Black Stone). Offer 2 Rakat behind Maqam Ibrahim.',
      'duaArabic': 'بِسْمِ اللَّهِ وَاللَّهُ أَكْبَرُ',
      'duaUrdu': 'اللہ کے نام سے اور اللہ سب سے بڑا ہے۔',
    },
    {
      'step': '3. Sa\'i between Safa & Marwah (سعی صفا و مروہ)',
      'desc': 'Walk 7 times between the hills of Safa and Marwah starting at Safa. Recite dhikr and supplications.',
      'duaArabic': 'إِنَّ الصَّفَا وَالْمَروَةَ مِن شَعَآئِرِ اللَّهِ',
      'duaUrdu': 'بے شک صفا اور مروہ اللہ کی نشانیوں میں سے ہیں۔',
    },
    {
      'step': '4. Halq or Taqsir (حلق یا قصر)',
      'desc': 'Shave (Halq) or trim (Taqsir) hair to complete Umrah rites or leave Ihram state.',
      'duaArabic': 'اللَّهُمَّ اغْفِرْ لِلْمُحَلِّقِينَ وَالْمُقَصِّرِينَ',
      'duaUrdu': 'اے اللہ! سر منڈوانے والوں اور بال کٹوانے والوں کی مغفرت فرما۔',
    },
    {
      'step': '5. Mina (8th Dhu al-Hijjah - Yawm at-Tarwiyah)',
      'desc': 'Proceed to Mina in Ihram on 8th Dhu al-Hijjah. Stay in tents and offer Dhuhr, Asr, Maghrib, Isha, and Fajr prayers.',
      'duaArabic': 'لَبَّيْكَ اللَّهُمَّ لَبَّيْكَ، لَبَّيْكَ لاَ شَرِيكَ لَكَ لَبَّيْكَ',
      'duaUrdu': 'میں حاضر ہوں اے اللہ میں حاضر ہوں، تیرا کوئی شریک نہیں۔',
    },
    {
      'step': '6. Arafat (9th Dhu al-Hijjah - Day of Arafah)',
      'desc': 'The peak of Hajj. Stand at Mount Arafat from noon until sunset engaged in Wuquf, prayer, and intense Istighfar.',
      'duaArabic': 'لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ',
      'duaUrdu': 'اللہ کے سوا کوئی معبود نہیں، وہ اکیلا ہے اس کا کوئی شریک نہیں، حکومت اور تعریف اسی کے لیے ہے۔',
    },
    {
      'step': '7. Muzdalifah (Night of 9th Dhu al-Hijjah)',
      'desc': 'Proceed after sunset to Muzdalifah. Pray Maghrib and Isha combined. Collect pebbles for Jamarat and sleep under the sky.',
      'duaArabic': 'فَاذْكُرُوا اللَّهَ عِندَ الْمَشْعَرِ الْحَرَامِ',
      'duaUrdu': 'پس مشعر الحرام (مزدلفہ) کے پاس اللہ کا ذکر کرو۔',
    },
    {
      'step': '8. Ramy al-Jamarat & Qurbani (10th Dhu al-Hijjah)',
      'desc': 'Pelting the Jamarat al-Aqaba with 7 pebbles, perform Qurbani (animal sacrifice), shave/trim hair, and perform Tawaf al-Ziyarah.',
      'duaArabic': 'اللَّهُ أَكْبَرُ',
      'duaUrdu': 'اللہ سب سے بڑا ہے۔',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Hajj & Umrah Guide (رہنمائے حج وعمرہ)', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppConstants.primaryGreen,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: hajjSteps.length,
        itemBuilder: (context, index) {
          final step = hajjSteps[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppConstants.primaryGreen.withOpacity(0.2)),
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
                Text(
                  step['step'] ?? '',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppConstants.primaryGreen,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  step['desc'] ?? '',
                  style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.4),
                ),
                const Divider(height: 24),
                const Text('Step Supplication / Dua:', style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Directionality(
                  textDirection: TextDirection.rtl,
                  child: Text(
                    step['duaArabic'] ?? '',
                    style: const TextStyle(
                      fontFamily: AppConstants.uthmaniFont,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppConstants.primaryGreen,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  step['duaUrdu'] ?? '',
                  style: const TextStyle(fontSize: 13, color: Colors.black87),
                  textDirection: TextDirection.rtl,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
