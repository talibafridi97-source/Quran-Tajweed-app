class KalmaModel {
  final int number;
  final String titleEnglish;
  final String titleUrdu;
  final String arabicText;
  final String urduMeaning;
  final String englishMeaning;

  const KalmaModel({
    required this.number,
    required this.titleEnglish,
    required this.titleUrdu,
    required this.arabicText,
    required this.urduMeaning,
    required this.englishMeaning,
  });

  static const List<KalmaModel> allKalmas = [
    KalmaModel(
      number: 1,
      titleEnglish: 'First Kalma: Tayyab',
      titleUrdu: 'پہلا کلمہ: طیب',
      arabicText: 'لَآ اِلٰهَ اِلَّا اللّٰهُ مُحَمَّدٌ رَّسُوْلُ اللّٰهِ',
      urduMeaning: 'اللہ کے سوا کوئی معبود نہیں، محمد اللہ کے رسول ہیں۔',
      englishMeaning: 'There is no god but Allah, Muhammad is the Messenger of Allah.',
    ),
    KalmaModel(
      number: 2,
      titleEnglish: 'Second Kalma: Shahadat',
      titleUrdu: 'دوسرا کلمہ: شہادت',
      arabicText: 'أَشْهَدُ أَنْ لَّآ إِلٰهَ إِلاَّ اللّٰهُ وَحْدَهُ لَا شَرِيْكَ لَهُ وَأَشْهَدُ أَنَّ مُحَمَّدًا عَبْدُهُ وَرَسُوْلُهُ',
      urduMeaning: 'میں گواہی دیتا ہوں کہ اللہ کے سوا کوئی معبود نہیں، وہ اکیلا ہے اس کا کوئی شریک نہیں اور میں گواہی دیتا ہوں کہ محمد اس کے بندے اور رسول ہیں۔',
      englishMeaning: 'I bear witness that there is no god but Allah, He is One, He has no partner, and I bear witness that Muhammad is His servant and Messenger.',
    ),
    KalmaModel(
      number: 3,
      titleEnglish: 'Third Kalma: Tamjeed',
      titleUrdu: 'تیسرا کلمہ: تمجید',
      arabicText: 'سُبْحَانَ اللّٰهِ وَالْحَمْدُ لِلّٰهِ وَلَآ إِلٰهَ إِلاَّ اللّٰهُ وَاللّٰهُ أَكْبَرُ وَلَا حَوْلَ وَلَا قُوَّةَ إِلاَّ بِاللّٰهِ الْعَلِيِّ الْعَظِيْمِ',
      urduMeaning: 'اللہ پاک ہے اور تمام تعریفیں اللہ ہی کے لیے ہیں اور اللہ کے سوا کوئی معبود نہیں اور اللہ سب سے بڑا ہے اور گناہوں سے بچنے کی طاقت اور نیکی کی توفیق نہیں مگر اللہ کی طرف سے جو بلند و برتر اور عظمت والا ہے۔',
      englishMeaning: 'Glory be to Allah, All praise be to Allah, there is no god but Allah, Allah is Most Great, and there is no power nor strength except with Allah, the Highest, the Most Great.',
    ),
    KalmaModel(
      number: 4,
      titleEnglish: 'Fourth Kalma: Tauheed',
      titleUrdu: 'چوتھا کلمہ: توحید',
      arabicText: 'لَآ إِلٰهَ إِلاَّ اللّٰهُ وَحْدَهُ لَا شَرِيْكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ يُحْيِي وَيُمِيْتُ وَهُوَ حَيٌّ لَّا يَمُوْتُ أَبَدًا أَبَدًا، ذُو الْجَلَالِ وَالْإِكْرَامِ، بِيَدِهِ الْخَيْرُ، وَهُوَ عَلٰى كُلِّ شَيْءٍ قَدِيْرٌ',
      urduMeaning: 'اللہ کے سوا کوئی معبود نہیں، وہ اکیلا ہے، اس کا کوئی شریک نہیں، اسی کے لیے بادشاہی ہے اور اسی کے لیے حمد ہے، وہی جلاتا ہے اور مارتا ہے اور وہ زندہ ہے جسے کبھی موت نہیں آئے گی، ہمیشہ ہمیشہ کے لیے، عظمت اور بزرگی والا ہے، اسی کے ہاتھ میں بھلائی ہے اور وہ ہر چیز پر قادر ہے۔',
      englishMeaning: 'There is no god but Allah, He is One, He has no partner, to Him belongs the Kingdom and All Praise, He gives life and causes death, and He is Alive and never dies, Possessor of Majesty and Honor, in His hand is all good and He has power over all things.',
    ),
    KalmaModel(
      number: 5,
      titleEnglish: 'Fifth Kalma: Astaghfar',
      titleUrdu: 'پانچواں کلمہ: استغفار',
      arabicText: 'أَسْتَغْفِرُ اللّٰهَ رَبِّي مِنْ كُلِّ ذَنْبٍ أَذْنَبْتُهُ عَمَدًا أَوْ خَطَأً سِرًّا أَوْ عَلَانِيَةً وَأَتُوْبُ إِلَيْهِ مِنَ الذَّنْبِ الَّذِيْ أَعْلَمُ وَمِنَ الذَّنْبِ الَّذِيْ لَآ أَعْلَمُ، إِنَّكَ أَنْتَ عَلَّامُ الْغُيُوْبِ وَسَتَّارُ الْعُيُوْبِ وَغَفَّارُ الذُّنُوْبِ وَلَا حَوْلَ وَلَا قُوَّةَ إِلاَّ بِاللّٰهِ الْعَلِيِّ الْعَظِيْمِ',
      urduMeaning: 'میں اللہ سے معافی مانگتا ہوں جو میرا رب ہے ہر اس گناہ سے جو میں نے جان بوجھ کر کیا یا بھول کر، چھپ کر کیا یا علانیہ، اور میں اس کے حضور توبہ کرتا ہوں اس گناہ سے جسے میں جانتا ہوں اور اس گناہ سے جسے میں نہیں جانتا، بے شک تو غیب کا جاننے والا اور عیبوں کو چھپانے والا اور گناہوں کو بخشنے والا ہے اور گناہوں سے بچنے کی طاقت اور نیکی کرنے کی توفیق اللہ کے بغیر نہیں۔',
      englishMeaning: 'I seek forgiveness from Allah, my Lord, for every sin I committed knowingly or unknowingly, secretly or openly, and I turn to Him in repentance from the sin that I know and from the sin that I do not know. Indeed, You are the Knower of the unseen, the Concealer of faults, and the Forgiver of sins.',
    ),
    KalmaModel(
      number: 6,
      titleEnglish: 'Sixth Kalma: Radd-e-Kufr',
      titleUrdu: 'چھٹا کلمہ: رد کفر',
      arabicText: 'اَللّٰهُمَّ إِنِّيْ أَعُوْذُ بِكَ مِنْ أَنْ أُشْرِكَ بِكَ شَيْئًا وَّأَنَا أَعْلَمُ بِهِ وَأَسْتَغْفِرُكَ لِمَا لَا أَعْلَمُ بِهِ تُبْتُ عَنْهُ وَتَبَرَّأْتُ مِنَ الْكُفْرِ وَالشِّرْكِ وَالْكِذْبِ وَالْغِيْبَةِ وَالْبِدْعَةِ وَالنَّمِيْمَةِ وَالْفَوَاحِشِ وَالْبُهْتَانِ وَالْمَعَاصِي كُلِّهَا وَأَسْلَمْتُ وَأَقُوْلُ لَآ إِلٰهَ إِلاَّ اللّٰهُ مُحَمَّدٌ رَّسُوْلُ اللّٰهِ',
      urduMeaning: 'اے اللہ! میں تیری پناہ مانگتا ہوں اس بات سے کہ میں کسی چیز کو تیرا شریک بناؤں جبکہ میں اسے جانتا ہوں، اور میں تجھ سے معافی مانگتا ہوں اس گناہ کی جسے میں نہیں جانتا، میں نے اس سے توبہ کی اور بیزار ہوا کفر، شرک، جھوٹ، غیبت، بدعت، چغلی، بے حیائی، تہمات اور تمام گناہوں سے، اور میں اسلام لایا اور کہتا ہوں: اللہ کے سوا کوئی معبود نہیں، محمد اللہ کے رسول ہیں۔',
      englishMeaning: 'O Allah! I seek refuge in You from associating anything with You knowingly, and I seek Your forgiveness for that which I do not know. I repent from it and disassociate myself from disbelief, polytheism, lies, backbiting, innovation, slander, indecencies, and all sins, and I submit and say: There is no god but Allah, Muhammad is the Messenger of Allah.',
    ),
  ];
}
