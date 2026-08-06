import 'package:flutter/material.dart';

class AppConstants {
  static const String appName = 'Tajweed Quran';
  static const String baseUrl = 'https://api.alquran.cloud/v1';

  // Colors
  static const Color primaryGreen = Color(0xFF006400);
  static const Color accentGreen = Color(0xFF008000);
  static const Color lightGreen = Color(0xFF90EE90);
  static const Color darkGreen = Color(0xFF004d00);
  
  // Storage Keys
  static const String lastReadSurahKey = 'last_read_surah';
  static const String lastReadAyahKey = 'last_read_ayah';
  static const String lastReadPageKey = 'last_read_page';
  static const String lastReadJuzKey = 'last_read_juz';
  static const String bookmarksKey = 'bookmarks';
  // Fonts
  static const String uthmaniFont = 'Uthmani';
  static const String urduFont = 'JameelNoori';
  static const String kitabFont = 'Kitab';
}
