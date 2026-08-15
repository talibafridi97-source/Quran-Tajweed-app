import 'package:flutter/material.dart';
import '../../screens/splash/splash_screen.dart';
import '../../screens/home/home_screen.dart';
import '../../screens/surah/surah_list_screen.dart';
import '../../screens/juz/juz_list_screen.dart';
import '../../screens/page/quran_page_screen.dart';
import '../../screens/hadith/hadith_books_screen.dart';
import '../../screens/settings/settings_screen.dart';
import '../../screens/duas/duas_screen.dart';
import '../../screens/kalmas/kalmas_screen.dart';
import '../../screens/allah_names/allah_names_screen.dart';
import '../../screens/qibla/qibla_screen.dart';
import '../../screens/prayer_times/prayer_times_screen.dart';
import '../../screens/tasbeeh/tasbeeh_screen.dart';
import '../../screens/calendar/islamic_calendar_screen.dart';
import '../../screens/khatam/khatam_tracker_screen.dart';
import '../../screens/hajj/hajj_guide_screen.dart';
import '../../screens/zakat/zakat_calculator_screen.dart';
import '../../screens/daily_ayah/daily_ayah_screen.dart';
import '../../screens/tajweed/tajweed_rules_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String home = '/home';
  static const String surahList = '/surah-list';
  static const String juzList = '/juz-list';
  static const String quranPage = '/quran-page';
  static const String hadithBooks = '/hadith-books';
  static const String settings = '/settings';
  static const String duas = '/duas';
  static const String kalmas = '/kalmas';
  static const String allahNames = '/allah-names';
  static const String qibla = '/qibla';
  static const String prayerTimes = '/prayer-times';
  static const String tasbeeh = '/tasbeeh';
  static const String calendar = '/calendar';
  static const String khatam = '/khatam';
  static const String hajjGuide = '/hajj-guide';
  static const String zakatCalculator = '/zakat-calculator';
  static const String dailyAyah = '/daily-ayah';
  static const String tajweedRules = '/tajweed-rules';

  static Map<String, WidgetBuilder> get routes => {
    splash: (context) => const SplashScreen(),
    home: (context) => const HomeScreen(),
    surahList: (context) => const SurahListScreen(),
    juzList: (context) => const JuzListScreen(),
    quranPage: (context) => const QuranPageScreen(),
    hadithBooks: (context) => const HadithBooksScreen(),
    settings: (context) => const SettingsScreen(),
    duas: (context) => const DuasScreen(),
    kalmas: (context) => const KalmasScreen(),
    allahNames: (context) => const AllahNamesScreen(),
    qibla: (context) => const QiblaScreen(),
    prayerTimes: (context) => const PrayerTimesScreen(),
    tasbeeh: (context) => const TasbeehScreen(),
    calendar: (context) => const IslamicCalendarScreen(),
    khatam: (context) => const KhatamTrackerScreen(),
    hajjGuide: (context) => const HajjGuideScreen(),
    zakatCalculator: (context) => const ZakatCalculatorScreen(),
    dailyAyah: (context) => const DailyAyahScreen(),
    tajweedRules: (context) => const TajweedRulesScreen(),
  };
}
