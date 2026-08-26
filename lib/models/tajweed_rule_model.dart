import 'package:flutter/material.dart';

enum TajweedCategory {
  noonSakinah('Noon Sakin & Tanween', 'احکام نون ساکن و تنوین', Icons.grain),
  meemSakinah('Meem Sakin', 'احکام میم ساکن', Icons.waves),
  madd('Madd (Prolongations)', 'احکام مد', Icons.timeline),
  qalqalah('Qalqalah (Echoing)', 'احکام قلقلہ', Icons.graphic_eq),
  lamRules('Rules of Lam', 'احکام لام', Icons.auto_stories),
  raRules('Rules of Ra', 'احکام راء', Icons.record_voice_over),
  waqfSigns('Waqf & Stopping Signs', 'رموز اوقاف', Icons.pan_tool_alt),
  quranSymbols('Quranic Symbols', 'رموز و علامات', Icons.auto_awesome);

  final String titleEnglish;
  final String titleUrdu;
  final IconData icon;

  const TajweedCategory(this.titleEnglish, this.titleUrdu, this.icon);
}

class TajweedRuleModel {
  final String id;
  final TajweedCategory category;
  final String titleEnglish;
  final String titleArabic;
  final String titleUrdu;
  final String explanationEnglish;
  final String explanationUrdu;
  final String ruleLetters;
  final String authenticExampleArabic;
  final String surahRef;
  final Color ruleColor;
  final String pronunciationTip;
  final String? audioUrl;

  const TajweedRuleModel({
    required this.id,
    required this.category,
    required this.titleEnglish,
    required this.titleArabic,
    required this.titleUrdu,
    required this.explanationEnglish,
    required this.explanationUrdu,
    required this.ruleLetters,
    required this.authenticExampleArabic,
    required this.surahRef,
    required this.ruleColor,
    required this.pronunciationTip,
    this.audioUrl,
  });

  static const List<TajweedRuleModel> allRules = [
    // 1. Ghunnah
    TajweedRuleModel(
      id: 'ghunnah',
      category: TajweedCategory.noonSakinah,
      titleEnglish: 'Ghunnah',
      titleArabic: 'الغُنَّة',
      titleUrdu: 'غنہ',
      explanationEnglish: 'A nasal sound produced from the nose cavity for the duration of 2 counts on Noon Mushaddad (نَّ) or Meem Mushaddad (مَّ).',
      explanationUrdu: 'نون مشدد (نَّ) یا میم مشدد (مَّ) پر دو حرکات کی مقدار ناک کے بانسے سے گنگنی آواز نکالنا۔',
      ruleLetters: 'نّ ، مّ',
      authenticExampleArabic: 'إِنَّ ٱللَّهَ مَعَ ٱلصَّٰبِرِينَ',
      surahRef: 'Surah Al-Baqarah 2:153',
      ruleColor: Color(0xFFFF7E1E), // Vibrant Orange
      pronunciationTip: 'Hold the nasal vibration steadily in the nasal passage without rushing.',
      audioUrl: 'https://cdn.islamic.network/quran/audio/128/ar.alafasy/160.mp3',
    ),

    // 2. Izhar Halqi
    TajweedRuleModel(
      id: 'izhar_halqi',
      category: TajweedCategory.noonSakinah,
      titleEnglish: 'Izhar Halqi',
      titleArabic: 'الإظهار الحلقي',
      titleUrdu: 'اظہارِ حلقی',
      explanationEnglish: 'Pronouncing Noon Sakinah (نْ) or Tanween clearly and distinctly without Ghunnah when followed by the 6 throat letters.',
      explanationUrdu: 'نون ساکن یا تنوین کے بعد اگر 6 حروفِ حلقی (أ هـ ع ح غ خ) میں سے کوئی آئے تو بغیر غنہ کے صاف و واضح پڑھنا۔',
      ruleLetters: 'ء ، هـ ، ع ، ح ، غ ، خ',
      authenticExampleArabic: 'صِرَٰطَ ٱلَّذِينَ أَنْعَمْتَ عَلَيْهِمْ',
      surahRef: 'Surah Al-Fatihah 1:7',
      ruleColor: Color(0xFF7F8C8D), // Slate Gray / Clear
      pronunciationTip: 'Touch the tongue firmly against the upper gums to pronounce Noon clearly without prolonging.',
      audioUrl: 'https://cdn.islamic.network/quran/audio/128/ar.alafasy/7.mp3',
    ),

    // 3. Ikhfa Haqiqi
    TajweedRuleModel(
      id: 'ikhfa_haqiqi',
      category: TajweedCategory.noonSakinah,
      titleEnglish: 'Ikhfa Haqiqi',
      titleArabic: 'الإخفاء الحقيقي',
      titleUrdu: 'اخفاء حقیقی',
      explanationEnglish: 'Concealing the sound of Noon Sakinah or Tanween with a light nasal Ghunnah (2 counts) before 15 specific letters.',
      explanationUrdu: 'نون ساکن یا تنوین کو اخفاء کے 15 حروف سے پہلے ناک میں چھپا کر 2 حرکات غنہ کے ساتھ ادا کرنا۔',
      ruleLetters: 'ت ث ج د ذ ز س ش ص ض ط ظ ف ق ك',
      authenticExampleArabic: 'كُنتُمْ خَيْرَ أُمَّةٍ أُخْرِجَتْ لِلنَّاسِ',
      surahRef: 'Surah Ali \'Imran 3:110',
      ruleColor: Color(0xFF8E24AA), // Royal Purple
      pronunciationTip: 'Keep your tongue near the articulation point of the following letter while letting the sound resonate in the nose.',
      audioUrl: 'https://cdn.islamic.network/quran/audio/128/ar.alafasy/403.mp3',
    ),

    // 4. Idgham with Ghunnah
    TajweedRuleModel(
      id: 'idgham_ghunnah',
      category: TajweedCategory.noonSakinah,
      titleEnglish: 'Idgham with Ghunnah',
      titleArabic: 'الإدغام بغنة',
      titleUrdu: 'ادغام مع الغنہ',
      explanationEnglish: 'Merging Noon Sakinah or Tanween into the next letter with complete Ghunnah (2 counts) when followed by Ya, Noon, Meem, Waw (يَنْمُو).',
      explanationUrdu: 'نون ساکن یا تنوین کو حروفِ ينمو (ی ، ن ، م ، و) میں ملا کر 2 حرکات غنہ کے ساتھ پڑھنا۔',
      ruleLetters: 'ي ، ن ، م ، و',
      authenticExampleArabic: 'وَمَن يَعْمَلْ مِثْقَالَ ذَرَّةٍ خَيْرًا يَرَهُ',
      surahRef: 'Surah Az-Zalzalah 99:7',
      ruleColor: Color(0xFF00897B), // Emerald Teal
      pronunciationTip: 'Blend the Noon seamlessly into the next letter while sustaining nasal resonance.',
      audioUrl: 'https://cdn.islamic.network/quran/audio/128/ar.alafasy/6145.mp3',
    ),

    // 5. Idgham without Ghunnah
    TajweedRuleModel(
      id: 'idgham_no_ghunnah',
      category: TajweedCategory.noonSakinah,
      titleEnglish: 'Idgham without Ghunnah',
      titleArabic: 'الإدغام بغير غنة',
      titleUrdu: 'ادغام بلا غنہ',
      explanationEnglish: 'Complete blending of Noon Sakinah or Tanween into the letter Lam (ل) or Ra (ر) with zero nasalization.',
      explanationUrdu: 'نون ساکن یا تنوین کو لام (ل) یا راء (ر) میں بغیر کسی غنہ کے مکمل طور پر مدغم کر دینا۔',
      ruleLetters: 'ل ، ر',
      authenticExampleArabic: 'أُوْلَٰٓئِكَ عَلَىٰ هُدًى مِّن رَّبِّهِمْ',
      surahRef: 'Surah Al-Baqarah 2:5',
      ruleColor: Color(0xFF00897B), // Teal
      pronunciationTip: 'Pronounce the Lam or Ra with full clarity and Shaddah, bypassing any nasal tone.',
      audioUrl: 'https://cdn.islamic.network/quran/audio/128/ar.alafasy/12.mp3',
    ),

    // 6. Iqlab
    TajweedRuleModel(
      id: 'iqlab',
      category: TajweedCategory.noonSakinah,
      titleEnglish: 'Iqlab (Conversion)',
      titleArabic: 'الإقلاب',
      titleUrdu: 'اقلاب',
      explanationEnglish: 'Converting Noon Sakinah or Tanween into a gentle Meem (م) sound with Ghunnah (2 counts) when followed by the letter Ba (ب).',
      explanationUrdu: 'نون ساکن یا تنوین کے بعد حرفِ باء (ب) آئے تو اسے چھوٹی میم (م) سے بدل کر غنہ کے ساتھ پڑھنا۔',
      ruleLetters: 'ب (with small meem ۢ)',
      authenticExampleArabic: 'كَلَّا لَيُنبَذَنَّ فِي ٱلْحُطَمَةِ',
      surahRef: 'Surah Al-Humazah 104:4',
      ruleColor: Color(0xFF00B0FF), // Sky Cyan
      pronunciationTip: 'Lightly close the lips to form a soft Meem sound without pressing tightly.',
      audioUrl: 'https://cdn.islamic.network/quran/audio/128/ar.alafasy/6182.mp3',
    ),

    // 7. Meem Sakin - Ikhfa Shafawi
    TajweedRuleModel(
      id: 'ikhfa_shafawi',
      category: TajweedCategory.meemSakinah,
      titleEnglish: 'Ikhfa Shafawi',
      titleArabic: 'الإخفاء الشفوي',
      titleUrdu: 'اخفاء شفوی',
      explanationEnglish: 'Concealing Meem Sakinah (مْ) with Ghunnah when followed by the letter Ba (ب).',
      explanationUrdu: 'میم ساکن (مْ) کے بعد حرفِ باء (ب) آئے تو غنہ کے ساتھ ہونٹوں کو ہلکا ملا کر چھپا کر پڑھنا۔',
      ruleLetters: 'مْ + ب',
      authenticExampleArabic: 'تَرْمِيهِم بِحِجَارَةٍ مِّن سِجِّيلٍ',
      surahRef: 'Surah Al-Fil 105:4',
      ruleColor: Color(0xFF8E24AA), // Purple
      pronunciationTip: 'Gently touch the lips together without pressing, sustaining the nasal sound for 2 counts.',
      audioUrl: 'https://cdn.islamic.network/quran/audio/128/ar.alafasy/6188.mp3',
    ),

    // 8. Meem Sakin - Idgham Shafawi
    TajweedRuleModel(
      id: 'idgham_shafawi',
      category: TajweedCategory.meemSakinah,
      titleEnglish: 'Idgham Shafawi',
      titleArabic: 'الإدغام الشفوي',
      titleUrdu: 'ادغام شفوی / ادغام مثلی',
      explanationEnglish: 'Merging Meem Sakinah (مْ) into a subsequent Meem (م) with complete Ghunnah (2 counts).',
      explanationUrdu: 'میم ساکن (مْ) کے بعد دوسری متحرک میم (م) آئے تو دونوں کو ملا کر غنہ کے ساتھ پڑھنا۔',
      ruleLetters: 'مْ + م',
      authenticExampleArabic: 'لَهُم مَّا يَشَآءُونَ فِيهَا وَلَدَيْنَا مَزِيدٌ',
      surahRef: 'Surah Qaf 50:35',
      ruleColor: Color(0xFF00897B), // Emerald
      pronunciationTip: 'Merge into a single strengthened Meem with full 2-count nasal Ghunnah.',
      audioUrl: 'https://cdn.islamic.network/quran/audio/128/ar.alafasy/4665.mp3',
    ),

    // 9. Meem Sakin - Izhar Shafawi
    TajweedRuleModel(
      id: 'izhar_shafawi',
      category: TajweedCategory.meemSakinah,
      titleEnglish: 'Izhar Shafawi',
      titleArabic: 'الإظهار الشفوي',
      titleUrdu: 'اظہارِ شفوی',
      explanationEnglish: 'Pronouncing Meem Sakinah clearly without extra Ghunnah before any letter except Ba (ب) and Meem (م). Extra care before Waw (و) and Fa (ف).',
      explanationUrdu: 'میم ساکن کے بعد باء اور میم کے علاوہ تمام 26 حروف پر میم کو صاف و واضح بغیر غنہ کے پڑھنا۔',
      ruleLetters: 'All 26 letters except ب and م',
      authenticExampleArabic: 'أَلَمْ تَرَ كَيْفَ فَعَلَ رَبُّكَ بِأَصْحَٰبِ ٱلْفِيلِ',
      surahRef: 'Surah Al-Fil 105:1',
      ruleColor: Color(0xFF7F8C8D), // Gray
      pronunciationTip: 'Close the lips crisply and release cleanly without lingering.',
      audioUrl: 'https://cdn.islamic.network/quran/audio/128/ar.alafasy/6185.mp3',
    ),

    // 10. Qalqalah
    TajweedRuleModel(
      id: 'qalqalah',
      category: TajweedCategory.qalqalah,
      titleEnglish: 'Qalqalah (Echoing / Bouncing)',
      titleArabic: 'القلقلة',
      titleUrdu: 'قلقلہ (گونج)',
      explanationEnglish: 'Echoing or bouncing sound produced when pronouncing Qalqalah letters (ق ط ب ج د - Qutb Jad) when Sakin (ْ) or on Waqf.',
      explanationUrdu: 'حروفِ قطب جد (ق ، ط ، ب ، ج ، د) ساکن ہونے کی حالت میں مخرج میں ٹکر کھا کر گونج کے ساتھ ادا ہونا۔',
      ruleLetters: 'ق ، ط ، ب ، ج ، د (قُطْبُ جَدّ)',
      authenticExampleArabic: 'قُلْ هُوَ ٱللَّهُ أَحَدٌ ﴿١﴾ ٱللَّهُ ٱلصَّمَدُ ﴿٢﴾ لَمْ يَلِدْ وَلَمْ يُولَدْ',
      surahRef: 'Surah Al-Ikhlas 112:1-3',
      ruleColor: Color(0xFF0288D1), // Electric Blue
      pronunciationTip: 'Make a crisp rebound of sound without adding any vowel (Harakat) inflection.',
      audioUrl: 'https://cdn.islamic.network/quran/audio/128/ar.alafasy/6221.mp3',
    ),

    // 11. Madd Wajib Muttasil
    TajweedRuleModel(
      id: 'madd_muttasil',
      category: TajweedCategory.madd,
      titleEnglish: 'Madd Wajib Muttasil',
      titleArabic: 'المد الواجب المتصل',
      titleUrdu: 'مد واجب متصل',
      explanationEnglish: 'Mandatory prolongation of 4 to 5 counts when a Madd letter and Hamza (ء) appear inside the EXACT SAME word.',
      explanationUrdu: 'ایک ہی کلمے میں حرفِ مدہ کے بعد ہمزہ آئے تو آواز کو 4 یا 5 حرکات تک لمبا کرنا واجب ہے۔',
      ruleLetters: 'حرف مد + ء (In same word)',
      authenticExampleArabic: 'إِذَا جَآءَ نَصْرُ ٱللَّهِ وَٱلْفَتْحُ',
      surahRef: 'Surah An-Nasr 110:1',
      ruleColor: Color(0xFFD81B60), // Vibrant Magenta
      pronunciationTip: 'Stretch the sound smoothly for 4 to 5 counts without straining the voice.',
      audioUrl: 'https://cdn.islamic.network/quran/audio/128/ar.alafasy/6212.mp3',
    ),

    // 12. Madd Ja'iz Munfasil
    TajweedRuleModel(
      id: 'madd_munfasil',
      category: TajweedCategory.madd,
      titleEnglish: 'Madd Ja\'iz Munfasil',
      titleArabic: 'المد الجائز المنفصل',
      titleUrdu: 'مد جائز منفصل',
      explanationEnglish: 'Permissible prolongation of 4 to 5 counts when a Madd letter is at the end of one word and Hamza (ء) begins the next word.',
      explanationUrdu: 'حرفِ مدہ ایک کلمے کے آخر میں اور ہمزہ اگلے کلمے کے شروع میں آئے تو 4 یا 5 حرکات کھینچ کر پڑھنا جائز ہے۔',
      ruleLetters: 'Word 1 ends in Madd + Word 2 starts with ء',
      authenticExampleArabic: 'إِنَّآ أَعْطَيْنَٰكَ ٱلْكَوْثَرَ',
      surahRef: 'Surah Al-Kawthar 108:1',
      ruleColor: Color(0xFFD81B60), // Magenta
      pronunciationTip: 'Maintain even tempo when transitioning across the two separate words.',
      audioUrl: 'https://cdn.islamic.network/quran/audio/128/ar.alafasy/6204.mp3',
    ),

    // 13. Madd Lazim
    TajweedRuleModel(
      id: 'madd_lazim',
      category: TajweedCategory.madd,
      titleEnglish: 'Madd Lazim (Compulsory 6 Counts)',
      titleArabic: 'المد اللازم',
      titleUrdu: 'مد لازم',
      explanationEnglish: 'Obligatory 6-count elongation when a Madd letter is followed by a permanent original Sukoon or Shaddah.',
      explanationUrdu: 'حرفِ مدہ کے بعد اصلی سکون یا تشدید آئے تو آواز کو لازمی طور پر 6 حرکات کھینچنا لازم ہے۔',
      ruleLetters: 'حرف مد + تشدید / سکون اصلی',
      authenticExampleArabic: 'غَيْرِ ٱلْمَغْضُوبِ عَلَيْهِمْ وَلَا ٱلضَّآلِّينَ',
      surahRef: 'Surah Al-Fatihah 1:7',
      ruleColor: Color(0xFFC2185B), // Deep Magenta / Crimson
      pronunciationTip: 'Give full 6 beats of duration and press firmly into the subsequent doubled letter.',
      audioUrl: 'https://cdn.islamic.network/quran/audio/128/ar.alafasy/7.mp3',
    ),

    // 14. Rules of Lam - Lam Shamsiyyah
    TajweedRuleModel(
      id: 'lam_shamsiyyah',
      category: TajweedCategory.lamRules,
      titleEnglish: 'Lam Shamsiyyah (Sun Letters)',
      titleArabic: 'اللام الشمسية',
      titleUrdu: 'لامِ شمسیہ',
      explanationEnglish: 'The Lam of the Alif-Lam prefix (ال) becomes silent and merges into the following Sun letter, making it doubled (Mushaddad).',
      explanationUrdu: 'حروفِ شمسی سے پہلے الف لام کا لام نہیں پڑھا جاتا اور اگلا حرف مشدد ہو کر پڑھا جاتا ہے۔',
      ruleLetters: 'ت ث د ذ ر ز س ش ص ض ط ظ ل ن',
      authenticExampleArabic: 'ٱلشَّمْسُ وَٱلْقَمَرُ بِحُسْبَانٍ',
      surahRef: 'Surah Ar-Rahman 55:5',
      ruleColor: Color(0xFFF39C12), // Amber Gold
      pronunciationTip: 'Skip the Lam sound completely and glide straight from Alif into the doubled Sun letter.',
      audioUrl: 'https://cdn.islamic.network/quran/audio/128/ar.alafasy/4906.mp3',
    ),

    // 15. Rules of Lam - Lam of Jalalah
    TajweedRuleModel(
      id: 'lam_jalalah',
      category: TajweedCategory.lamRules,
      titleEnglish: 'Lam of Allah (Jalalah)',
      titleArabic: 'لام لفظ الجلالة',
      titleUrdu: 'لامِ لفظ جلالہ',
      explanationEnglish: 'The Lam in Allah (ٱللَّه) is pronounced heavy (Tafkheem) if preceded by Fathah or Dammah, and light (Tarqeeq) if preceded by Kasrah.',
      explanationUrdu: 'لفظ اللہ کا لام زبر یا پیش کے بعد موٹا (تفخیم) اور زیر کے بعد باریک (ترقیق) پڑھا جاتا ہے۔',
      ruleLetters: 'ٱللَّه (بعد فتحہ/ضمہ یا کسرہ)',
      authenticExampleArabic: 'إِنَّ ٱللَّهَ عَلَىٰ كُلِّ شَيْءٍ قَدِيرٌ',
      surahRef: 'Surah Al-Baqarah 2:20',
      ruleColor: Color(0xFF007A72), // Teal Green
      pronunciationTip: 'Fill the mouth with resonance for Tafkheem, and flatten the tongue for Tarqeeq in "Bismillah".',
      audioUrl: 'https://cdn.islamic.network/quran/audio/128/ar.alafasy/27.mp3',
    ),

    // 16. Rules of Ra - Tafkheem & Tarqeeq
    TajweedRuleModel(
      id: 'ra_rules',
      category: TajweedCategory.raRules,
      titleEnglish: 'Rules of Ra (Tafkheem & Tarqeeq)',
      titleArabic: 'أحكام الراء (تفخيم وترقيق)',
      titleUrdu: 'احکامِ راء (تفخیم و ترقیق)',
      explanationEnglish: 'The letter Ra (ر) is heavy (Tafkheem) with Fathah or Dammah, and light (Tarqeeq) with Kasrah or preceded by Ya Sakinah.',
      explanationUrdu: 'حرفِ راء زبر یا پیش پر پُر (موٹی) اور زیر یا یائے ساکن کے بعد باریک پڑھی جاتی ہے۔',
      ruleLetters: 'رَ / رُ (موٹا) ، رِ (باریک)',
      authenticExampleArabic: 'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ',
      surahRef: 'Surah Al-Fatihah 1:1',
      ruleColor: Color(0xFFE65100), // Orange
      pronunciationTip: 'Elevate the back of the tongue for heavy Ra and lower it for light Ra.',
      audioUrl: 'https://cdn.islamic.network/quran/audio/128/ar.alafasy/1.mp3',
    ),
  ];
}

class WaqfSymbolModel {
  final String symbol;
  final String titleArabic;
  final String titleEnglish;
  final String titleUrdu;
  final String meaning;
  final String rule;
  final String authenticQuranExample;
  final String surahRef;

  const WaqfSymbolModel({
    required this.symbol,
    required this.titleArabic,
    required this.titleEnglish,
    required this.titleUrdu,
    required this.meaning,
    required this.rule,
    required this.authenticQuranExample,
    required this.surahRef,
  });

  static const List<WaqfSymbolModel> allWaqfSymbols = [
    WaqfSymbolModel(
      symbol: 'مـ',
      titleArabic: 'الوقف اللازم',
      titleEnglish: 'Compulsory Stop (Waqf Lazim)',
      titleUrdu: 'وقف لازم',
      meaning: 'Mandatory Stop: You must stop here to preserve the authentic meaning of the verse.',
      rule: 'Stopping is compulsory. Continuing alters the context drastically.',
      authenticQuranExample: 'إِنَّمَا يَسْتَجِيبُ ٱلَّذِينَ يَسْمَعُونَ ۘ وَٱلْمَوْتَىٰ يَبْعَثُهُمُ ٱللَّهُ',
      surahRef: 'Surah Al-An\'am 6:36',
    ),
    WaqfSymbolModel(
      symbol: 'ج',
      titleArabic: 'الوقف الجائز',
      titleEnglish: 'Permissible Stop (Waqf Ja\'iz)',
      titleUrdu: 'وقف جائز',
      meaning: 'Permissible Stop: Stopping and continuing are both completely valid with equal preference.',
      rule: 'You may choose to stop or continue without changing the intended meaning.',
      authenticQuranExample: 'نَحْنُ نَقُصُّ عَلَيْكَ نَبَأَهُم بِٱلْحَقِّ ۚ إِنَّهُمْ فِتْيَةٌ ءَامَنُوا۟ بِرَبِّهِمْ',
      surahRef: 'Surah Al-Kahf 18:13',
    ),
    WaqfSymbolModel(
      symbol: 'لا',
      titleArabic: 'لا تقف',
      titleEnglish: 'Do Not Stop (La Taqif)',
      titleUrdu: 'لا تقف (نہ رکیں)',
      meaning: 'Do Not Stop: The sentence meaning is incomplete. If out of breath, stop and repeat preceding word.',
      rule: 'Do not stop here. Continue reading without a pause unless breathing requires restarting.',
      authenticQuranExample: 'ٱلَّذِينَ تَتَوَفَّىٰهُمُ ٱلْمَلَٰٓئِكَةُ طَيِّبِينَ ۙ يَقُولُونَ سَلَٰمٌ عَلَيْكُمُ',
      surahRef: 'Surah An-Nahl 16:32',
    ),
    WaqfSymbolModel(
      symbol: 'صلى',
      titleArabic: 'الوصل أولى',
      titleEnglish: 'Better to Continue (Al-Waslu Awla)',
      titleUrdu: 'الوصل اولیٰ',
      meaning: 'Permissible to stop, but continuing is preferable.',
      rule: 'Continuing the recitation in one breath is superior, though stopping is allowed.',
      authenticQuranExample: 'وَإِن يَمْسَسْكَ ٱللَّهُ بِضُرٍّۢ فَلَا كَاشِفَ لَهُۥٓ إِلَّا هُوَ ۖ',
      surahRef: 'Surah Al-An\'am 6:17',
    ),
    WaqfSymbolModel(
      symbol: 'قلى',
      titleArabic: 'الوقف أولى',
      titleEnglish: 'Better to Stop (Al-Waqfu Awla)',
      titleUrdu: 'الوقف اولیٰ',
      meaning: 'Permissible to continue, but stopping is preferable.',
      rule: 'Stopping here is superior, though continuing without stopping is allowed.',
      authenticQuranExample: 'قُل رَّبِّىٓ أَعْلَمُ بِعِدَّتِهِم مَّا يَعْلَمُهُمْ إِلَّا قَلِيلٌۭ ۗ',
      surahRef: 'Surah Al-Kahf 18:22',
    ),
    WaqfSymbolModel(
      symbol: 'ۛ ... ۛ',
      titleArabic: 'وقف المعانقة / المراقبة',
      titleEnglish: 'Embracing Stop (Mu\'anaqah)',
      titleUrdu: 'وقف معانقہ / مراقبہ',
      meaning: 'Pair of three dots: Stop at ONE of the two marks, NEVER at both and not neither.',
      rule: 'If you stop at the first mark, continue through the second without stopping.',
      authenticQuranExample: 'ذَٰلِكَ ٱلْكِتَٰبُ لَا رَيْبَ ۛ فِيهِ ۛ هُدًۭى لِّلْمُتَّقِينَ',
      surahRef: 'Surah Al-Baqarah 2:2',
    ),
    WaqfSymbolModel(
      symbol: '۩',
      titleArabic: 'سجدة التلاوة',
      titleEnglish: 'Sajdah Tilawat (Prostration)',
      titleUrdu: 'سجدۂ تلاوت',
      meaning: 'Prostration Mark: Performing a Sajdah upon reciting or hearing this verse is Sunnah Mu\'akkadah.',
      rule: 'Perform a single Sujud upon completing this verse.',
      authenticQuranExample: 'كَلَّا لَا تُطِعْهُ وَٱسْجُدْ وَٱقْتَرِب ۩',
      surahRef: 'Surah Al-\'Alaq 96:19',
    ),
    WaqfSymbolModel(
      symbol: 'ۜ',
      titleArabic: 'السكتة',
      titleEnglish: 'Saktah (Brief Pause)',
      titleUrdu: 'سکتہ (مختصر وقفہ)',
      meaning: 'A brief pause in sound without taking a breath before continuing recitation.',
      rule: 'Hold the voice for a moment without inhaling breath, then resume.',
      authenticQuranExample: 'قَيِّمًۭا لِّيُنذِرَ بَأْسًۭا شَدِيدًۭا مِّن لَّدُنْهُ',
      surahRef: 'Surah Al-Kahf 18:2',
    ),
  ];
}
