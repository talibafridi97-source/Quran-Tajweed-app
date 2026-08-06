import 'package:flutter/material.dart';
import '../../screens/splash/splash_screen.dart';
import '../../screens/home/home_screen.dart';
import '../../screens/surah/surah_list_screen.dart';
import '../../screens/settings/settings_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String home = '/home';
  static const String surahList = '/surah-list';
  static const String surahDetail = '/surah-detail';
  static const String settings = '/settings';

  static Map<String, WidgetBuilder> get routes => {
    splash: (context) => const SplashScreen(),
    home: (context) => const HomeScreen(),
    surahList: (context) => const SurahListScreen(),
    settings: (context) => const SettingsScreen(),
  };
}
