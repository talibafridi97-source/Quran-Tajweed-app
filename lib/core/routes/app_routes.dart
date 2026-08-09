import 'package:flutter/material.dart';
import '../../screens/splash/splash_screen.dart';
import '../../screens/home/home_screen.dart';
import '../../screens/surah/surah_list_screen.dart';
import '../../screens/juz/juz_list_screen.dart';
import '../../screens/page/quran_page_screen.dart';
import '../../screens/hadith/hadith_books_screen.dart';
import '../../screens/settings/settings_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String home = '/home';
  static const String surahList = '/surah-list';
  static const String juzList = '/juz-list';
  static const String quranPage = '/quran-page';
  static const String hadithBooks = '/hadith-books';
  static const String settings = '/settings';

  static Map<String, WidgetBuilder> get routes => {
    splash: (context) => const SplashScreen(),
    home: (context) => const HomeScreen(),
    surahList: (context) => const SurahListScreen(),
    juzList: (context) => const JuzListScreen(),
    quranPage: (context) => const QuranPageScreen(),
    hadithBooks: (context) => const HadithBooksScreen(),
    settings: (context) => const SettingsScreen(),
  };
}
