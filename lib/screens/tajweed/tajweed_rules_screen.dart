import 'package:flutter/material.dart';
import '../../core/constants/constants.dart';
import '../../core/widgets/tajweed_text.dart';

class TajweedRulesScreen extends StatelessWidget {
  const TajweedRulesScreen({super.key});

  static const List<Map<String, dynamic>> tajweedRules = [
    {
      'title': 'Ghunnah (غنة)',
      'color': Color(0xFFFF7E1E), // Orange / Gold
      'english': 'Nasalization sound held for 2 counts on Noon Mushaddad (نَّ) or Meem Mushaddad (مَّ).',
      'urdu': 'نون مشدد (نَّ) یا میم مشدد (مَّ) پر دو حرکات کے برابر ناک سے آواز نکالنا۔',
      'example': 'إِنَّ ٱللَّهَ مَعَ ٱلصَّٰبِرِينَ',
      'surahRef': 'Surah Al-Baqarah 2:153',
    },
    {
      'title': 'Ikhfa (إخفاء)',
      'color': Color(0xFF9400D3), // Dark Violet
      'english': 'Concealing or hiding the sound of Noon Sakinah (نْ) or Tanween before 15 Ikhfa letters.',
      'urdu': 'نون ساکن یا تنوین کی آواز کو اخفاء کے 15 حروف سے پہلے چھپا کر ادا کرنا۔',
      'example': 'مِن قَبْلِكُمْ',
      'surahRef': 'Surah Al-Baqarah 2:183',
    },
    {
      'title': 'Idgham (إدغام)',
      'color': Color(0xFF16A085), // Teal / Green
      'english': 'Merging Noon Sakinah or Tanween into the following letter (Yarmaloon حروف يَرْمَلُون).',
      'urdu': 'نون ساکن یا تنوین کو اگلے حرف (يرملون) میں ملا کر پڑھنا۔',
      'example': 'مَن يَقُولُ',
      'surahRef': 'Surah Al-Baqarah 2:8',
    },
    {
      'title': 'Iqlab (إقلاب)',
      'color': Color(0xFF27AE60), // Green
      'english': 'Converting Noon Sakinah or Tanween into a Meem (م) sound when followed by the letter Ba (ب).',
      'urdu': 'نون ساکن یا تنوین کے بعد حرف باء (ب) آئے تو اسے میم سے بدل کر پڑھنا۔',
      'example': 'مِنۢ بَعْدِ مَا جَاءَتْهُمُ',
      'surahRef': 'Surah Al-Baqarah 2:213',
    },
    {
      'title': 'Qalqalah (قلقلة)',
      'color': Color(0xFFDD2C00), // Red / Deep Orange
      'english': 'Echoing or bouncing sound produced when pronouncing Qalqalah letters (ق ط ب ج د) when Sakin.',
      'urdu': 'حروف قطب جد (ق ط ب ج د) ساکن ہونے کی حالت میں ان میں ٹکر کی آواز (گونج) پیدا کرنا۔',
      'example': 'قُلْ هُوَ ٱللَّهُ أَحَدٌ ﴿١﴾ ٱللَّهُ ٱلصَّمَدُ ﴿٢﴾ لَمْ يَلِدْ وَلَمْ يُولَدْ',
      'surahRef': 'Surah Al-Ikhlas 112:1-3',
    },
    {
      'title': 'Madd (مدّ)',
      'color': Color(0xFFE74C3C), // Crimson Red
      'english': 'Prolongation or stretching of vowel sound (Alif, Waw, Ya) for 2 to 6 counts.',
      'urdu': 'حروف مدہ (الف، واؤ، یاء) کے بعد سبب مد آنے پر آواز کو لمبا کرنا۔',
      'example': 'ٱلصَّٰٓخَّةُ',
      'surahRef': 'Surah Abasa 80:33',
    },
    {
      'title': 'Ikhfa Shafawi (إخفاء شفوي)',
      'color': Color(0xFF8E44AD), // Purple
      'english': 'Hiding Meem Sakinah (مْ) with Ghunnah when followed by the letter Ba (ب).',
      'urdu': 'میم ساکن (مْ) کے بعد حرف باء (ب) آئے تو غنہ کے ساتھ چھپا کر پڑھنا۔',
      'example': 'تَرْمِيهِم بِحِجَارَةٍ',
      'surahRef': 'Surah Al-Fil 105:4',
    },
    {
      'title': 'Idgham Shafawi (إدغام شفوي)',
      'color': Color(0xFF2980B9), // Blue
      'english': 'Merging Meem Sakinah (مْ) into another Meem (م) with Ghunnah.',
      'urdu': 'میم ساکن (مْ) کو دوسری میم (م) میں غنہ کے ساتھ مدغم کرنا۔',
      'example': 'لَهُم مَّا يَشَاءُونَ',
      'surahRef': 'Surah Qaf 50:35',
    },
    {
      'title': 'Izhar (إظهار)',
      'color': Color(0xFF7F8C8D), // Grey / Clear
      'english': 'Pronouncing Noon Sakinah or Tanween clearly without Ghunnah before throat letters (أ هـ ع ح غ خ).',
      'urdu': 'نون ساکن یا تنوین کو حروف حلقی سے پہلے بغیر غنہ کے صاف اور واضح پڑھنا۔',
      'example': 'مَنْ آمَنَ',
      'surahRef': 'Surah Al-Baqarah 2:62',
    },
    {
      'title': 'Lam Shamsiyyah (لام شمسية)',
      'color': Color(0xFFF39C12), // Amber
      'english': 'Silent Lam (ل) in Alif-Lam prefix before Sun letters (حروف شمسية).',
      'urdu': 'حروف شمسی سے پہلے ال کا لام نہ پڑھا جانا اور اگلے حرف کو مشدد کرنا۔',
      'example': 'ٱلشَّمْسُ وَٱلْقَمَرُ',
      'surahRef': 'Surah Ar-Rahman 55:5',
    },
    {
      'title': 'Hamzatul Wasl (همزة الوصل)',
      'color': Color(0xFF34495E), // Dark Slate
      'english': 'Connecting Hamza that is pronounced when starting a sentence but dropped during continuous reading.',
      'urdu': 'وہ ہمزہ جو ابتداء میں پڑھا جائے لیکن درمیان میں گر جائے۔',
      'example': 'ٱهْدِنَا ٱلصِّرَٰطَ ٱلْمُسْتَقِيمَ',
      'surahRef': 'Surah Al-Fatihah 1:6',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Tajweed Rules (أحكام التجويد)', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppConstants.primaryGreen,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: tajweedRules.length,
        itemBuilder: (context, index) {
          final rule = tajweedRules[index];
          final Color badgeColor = rule['color'] as Color;

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        rule['title'] as String,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: badgeColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: badgeColor),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: badgeColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Color Guide',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: badgeColor),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),
                Text(
                  rule['english'] as String,
                  style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.85), height: 1.4),
                ),
                const SizedBox(height: 6),
                Text(
                  rule['urdu'] as String,
                  style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
                  textDirection: TextDirection.rtl,
                ),

                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Quranic Example:', style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
                    Text(
                      rule['surahRef'] as String,
                      style: const TextStyle(fontSize: 11, color: AppConstants.primaryGreen, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Verified Quran Arabic Calligraphic Example
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: badgeColor.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: badgeColor.withOpacity(0.2)),
                  ),
                  child: TajweedText(
                    rawText: rule['example'] as String,
                    fontSize: 24,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
