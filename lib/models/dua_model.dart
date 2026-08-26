class MasnoonDua {
  final int id;
  final String duaId;
  final String titleEnglish;
  final String titleUrdu;
  final String category;
  final String arabicText;
  final String urduTranslation;
  final String englishTranslation;
  final String reference;
  final String audioUrl;

  const MasnoonDua({
    required this.id,
    required this.duaId,
    required this.titleEnglish,
    required this.titleUrdu,
    required this.category,
    required this.arabicText,
    required this.urduTranslation,
    required this.englishTranslation,
    required this.reference,
    required this.audioUrl,
  });

  static const List<MasnoonDua> allDuas = [
    MasnoonDua(
      id: 1,
      duaId: 'dua_1',
      titleEnglish: 'Before Sleeping',
      titleUrdu: 'سوتے وقت کی دعا',
      category: 'Daily',
      arabicText: 'بِاسْمِكَ رَبِّى وَضَعْتُ جَنْبِى وَبِكَ أَرْفَعُهُ',
      urduTranslation: 'اے میرے رب! تیرے نام کے ساتھ میں نے اپنا پہلو رکھا اور تیرے ہی نام کے ساتھ میں اسے اٹھاؤں گا۔',
      englishTranslation: 'In Your name my Lord, I lie down and in Your name I rise.',
      reference: 'Sahih al-Bukhari 6320',
      audioUrl: 'https://cdn.jsdelivr.net/gh/rn0x/Adhkar-json@main/audio/102.mp3',
    ),
    MasnoonDua(
      id: 2,
      duaId: 'dua_2',
      titleEnglish: 'Upon Waking Up',
      titleUrdu: 'سو کر اٹھنے کی دعا',
      category: 'Daily',
      arabicText: 'الْحَمْدُ لِلَّهِ الَّذِي أَحْيَانَا بَعْدَ مَا أَمَاتَنَا وَإِلَيْهِ النُّشُورُ',
      urduTranslation: 'تمام تعریفیں اللہ کے لیے ہیں جس نے ہمیں مارنے کے بعد زندہ کیا اور اسی کی طرف لوٹ کر جانا ہے۔',
      englishTranslation: 'Praise is to Allah Who gave us life after he caused us to die and unto Him is the resurrection.',
      reference: 'Sahih al-Bukhari 6312',
      audioUrl: 'https://cdn.jsdelivr.net/gh/rn0x/Adhkar-json@main/audio/1.mp3',
    ),
    MasnoonDua(
      id: 3,
      duaId: 'dua_3',
      titleEnglish: 'Before Eating',
      titleUrdu: 'کھانا کھانے سے پہلے کی دعا',
      category: 'Food',
      arabicText: 'بِسْمِ اللَّهِ وَعَلَى بَرَكَةِ اللَّهِ',
      urduTranslation: 'اللہ کے نام کے ساتھ اور اللہ کی برکت پر (میں کھانا شروع کرتا ہوں)۔',
      englishTranslation: 'In the name of Allah and with the blessings of Allah.',
      reference: 'Al-Hakim 7084',
      audioUrl: 'https://cdn.jsdelivr.net/gh/rn0x/Adhkar-json@main/audio/211.mp3',
    ),
    MasnoonDua(
      id: 4,
      duaId: 'dua_4',
      titleEnglish: 'After Eating',
      titleUrdu: 'کھانا کھانے کے بعد کی دعا',
      category: 'Food',
      arabicText: 'الْحَمْدُ لِلَّهِ الَّذِي أَطْعَمَنَا وَسَقَانَا وَجَعَلَنَا مُسْلِمِينَ',
      urduTranslation: 'تمام تعریفیں اللہ کے لیے ہیں جس نے ہمیں کھلایا اور پلایا اور ہمیں مسلمان بنایا۔',
      englishTranslation: 'Praise be to Allah Who has fed us and given us drink and made us Muslims.',
      reference: 'Sunan Abu Dawood 3850',
      audioUrl: 'https://cdn.jsdelivr.net/gh/rn0x/Adhkar-json@main/audio/108.mp3',
    ),
    MasnoonDua(
      id: 5,
      duaId: 'dua_5',
      titleEnglish: 'Entering the Masjid',
      titleUrdu: 'مسجد میں داخل ہونے کی دعا',
      category: 'Masjid',
      arabicText: 'اللَّهُمَّ افْتَحْ لِي أَبْوَابَ رَحْمَتِكَ',
      urduTranslation: 'اے اللہ! میرے لیے اپنی رحمت کے دروازے کھول دے۔',
      englishTranslation: 'O Allah, open for me the doors of Your mercy.',
      reference: 'Sahih Muslim 713',
      audioUrl: 'https://cdn.jsdelivr.net/gh/rn0x/Adhkar-json@main/audio/20.mp3',
    ),
    MasnoonDua(
      id: 6,
      duaId: 'dua_6',
      titleEnglish: 'Leaving the Masjid',
      titleUrdu: 'مسجد سے نکلنے کی دعا',
      category: 'Masjid',
      arabicText: 'اللَّهُمَّ إِنِّي أَسْأَلُكَ مِنْ فَضْلِكَ',
      urduTranslation: 'اے اللہ! میں تجھ سے تیرے فضل کا سوال کرتا ہوں۔',
      englishTranslation: 'O Allah, I ask You from Your favor.',
      reference: 'Sahih Muslim 713',
      audioUrl: 'https://cdn.jsdelivr.net/gh/rn0x/Adhkar-json@main/audio/21.mp3',
    ),
    MasnoonDua(
      id: 7,
      duaId: 'dua_7',
      titleEnglish: 'Travel Dua (Vehicle)',
      titleUrdu: 'سواری پر بیٹھنے کی دعا',
      category: 'Travel',
      arabicText: 'سُبْحَانَ الَّذِي سَخَّرَ لَنَا هَذَا وَمَا كُنَّا لَهُ مُقْرِنِينَ وَإِنَّا إِلَى رَبِّنَا لَمُنْقَلِبُونَ',
      urduTranslation: 'پاک ہے وہ ذات جس نے اس کو ہمارے بس میں کر دیا حالانکہ ہم اسے قابو میں لانے والے نہ تھے، اور بے شک ہم اپنے رب کی طرف لوٹنے والے ہیں۔',
      englishTranslation: 'Glory is to Him Who has subjected this to us, and we could not have otherwise subdued it. And indeed, to our Lord we will return.',
      reference: 'Surah Az-Zukhruf 43:13-14',
      audioUrl: 'https://everyayah.com/data/Alafasy_128kbps/043013.mp3',
    ),
    MasnoonDua(
      id: 8,
      duaId: 'dua_8',
      titleEnglish: 'Dua for Forgiveness (Sayyidul Istighfar)',
      titleUrdu: 'سید الاستغفار',
      category: 'Forgiveness',
      arabicText: 'اللَّهُمَّ أَنْتَ رَبِّي لاَ إِلَهَ إِلاَّ أَنْتَ، خَلَقْتَنِي وَأَنَا عَبْدُكَ، وَأَنَا عَلَى عَهْدِكَ وَوَعْدِكَ مَا اسْتَطَعْتُ',
      urduTranslation: 'اے اللہ! تو ہی میرا رب ہے، تیرے سوا کوئی معبود نہیں۔ تو نے مجھے پیدا کیا اور میں تیرا بندہ ہوں اور اپنے عہد و وعدہ پر قائم ہوں۔',
      englishTranslation: 'O Allah, You are my Lord, none has the right to be worshipped except You. You created me and I am Your servant.',
      reference: 'Sahih al-Bukhari 6306',
      audioUrl: 'https://cdn.jsdelivr.net/gh/rn0x/Adhkar-json@main/audio/79.mp3',
    ),
    MasnoonDua(
      id: 9,
      duaId: 'dua_9',
      titleEnglish: 'Dua for Knowledge',
      titleUrdu: 'علم میں اضافے کی دعا',
      category: 'Knowledge',
      arabicText: 'رَبِّ زِدْنِي عِلْمًا',
      urduTranslation: 'اے میرے رب! میرے علم میں اضافہ فرما۔',
      englishTranslation: 'My Lord, increase me in knowledge.',
      reference: 'Surah Taha 20:114',
      audioUrl: 'https://everyayah.com/data/Alafasy_128kbps/020114.mp3',
    ),
    MasnoonDua(
      id: 10,
      duaId: 'dua_10',
      titleEnglish: 'Dua for Parents',
      titleUrdu: 'والدین کے لیے دعا',
      category: 'Family',
      arabicText: 'رَّبِّ ارْحَمْهُمَا كَمَا رَبَّيَانِي صَغِيرًا',
      urduTranslation: 'اے میرے رب! ان دونوں پر رحم فرما جیسے انہوں نے بچپن میں میری پرورش کی۔',
      englishTranslation: 'My Lord, have mercy upon them both as they brought me up when I was small.',
      reference: 'Surah Al-Isra 17:24',
      audioUrl: 'https://everyayah.com/data/Alafasy_128kbps/017024.mp3',
    ),
    MasnoonDua(
      id: 11,
      duaId: 'dua_11',
      titleEnglish: 'Dua in Distress / Grief',
      titleUrdu: 'غم اور پریشانی کی دعا',
      category: 'Distress',
      arabicText: 'لاَ إِلَهَ إِلاَّ أَنْتَ سُبْحَانَكَ إِنِّي كُنْتُ مِنَ الظَّالِمِينَ',
      urduTranslation: 'تیرے سوا کوئی معبود نہیں، تو پاک ہے، بے شک میں ہی ظالموں میں سے تھا۔',
      englishTranslation: 'There is no deity except You; exalted are You. Indeed, I have been of the wrongdoers.',
      reference: 'Surah Al-Anbiya 21:87',
      audioUrl: 'https://everyayah.com/data/Alafasy_128kbps/021087.mp3',
    ),
    MasnoonDua(
      id: 12,
      duaId: 'dua_12',
      titleEnglish: 'Entering Home',
      titleUrdu: 'گھر میں داخل ہونے کی دعا',
      category: 'Home',
      arabicText: 'اللَّهُمَّ إِنِّي أَسْأَلُكَ خَيْرَ الْمَوْلِجِ وَخَيْرَ الْمَخْرَجِ',
      urduTranslation: 'اے اللہ! میں تجھ سے داخل ہونے کی اور نکلنے کی بہتری کا سوال کرتا ہوں۔',
      englishTranslation: 'O Allah, I ask You for the best entering and the best exiting.',
      reference: 'Sunan Abu Dawood 5096',
      audioUrl: 'https://cdn.jsdelivr.net/gh/rn0x/Adhkar-json@main/audio/23.mp3',
    ),
    MasnoonDua(
      id: 13,
      duaId: 'dua_13',
      titleEnglish: 'Leaving Home',
      titleUrdu: 'گھر سے نکلنے کی دعا',
      category: 'Home',
      arabicText: 'بِسْمِ اللَّهِ تَوَكَّلْتُ عَلَى اللَّهِ لاَ حَوْلَ وَلاَ قُوَّةَ إِلاَّ بِاللَّهِ',
      urduTranslation: 'اللہ کے نام سے، میں نے اللہ پر توکل کیا، اللہ کی مدد کے بغیر نہ گناہوں سے بچنے کی طاقت ہے نہ نیکی کرنے کی قوت۔',
      englishTranslation: 'In the name of Allah, I place my trust in Allah; there is no might nor power except through Allah.',
      reference: 'Sunan Abu Dawood 5095',
      audioUrl: 'https://cdn.jsdelivr.net/gh/rn0x/Adhkar-json@main/audio/22.mp3',
    ),
  ];
}

/// Dedicated, deterministic audio resolver for Masnoon Duas
class DuaAudioResolver {
  static final Map<String, MasnoonDua> _duasById = {
    for (final dua in MasnoonDua.allDuas) dua.duaId: dua,
  };

  /// Resolves the authentic Dua and its verified audio URL strictly by its immutable [duaId].
  /// Throws an [ArgumentError] if the ID does not exist, ensuring no fallback to other Duas.
  static MasnoonDua getDuaById(String duaId) {
    final dua = _duasById[duaId];
    if (dua == null) {
      throw ArgumentError('Invalid Dua ID: "$duaId". No Dua matches this identifier.');
    }
    return dua;
  }

  /// Resolves the verified audio URL strictly for [duaId].
  static String resolveAudioUrl(String duaId) {
    final dua = getDuaById(duaId);
    if (dua.audioUrl.isEmpty) {
      throw StateError('Dua "$duaId" has no audio URL configured.');
    }
    return dua.audioUrl;
  }

  /// Validates whether a given [duaId] and [audioUrl] belong strictly to the same Dua entity.
  static bool validateDuaAudioMapping(String duaId, String audioUrl) {
    final dua = _duasById[duaId];
    if (dua == null) return false;
    return dua.audioUrl == audioUrl;
  }
}
