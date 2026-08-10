import 'package:flutter/material.dart';

class AppConstants {
  static const String appName = 'Tajweed Quran';
  static const String baseUrl = 'https://api.alquran.cloud/v1';

  // Brand Colors
  static const Color primaryGreen = Color(0xFF0D4D4D);
  static const Color deepGreen = Color(0xFF0A3A3A);
  static const Color accentGreen = Color(0xFF00BFA5);
  static const Color gold = Color(0xFFC9A227);
  static const Color danger = Color(0xFFE0534E);
  static const Color accentMint = Color(0xFF26A69A);

  // Modern Colorful Accent Colors
  static const Color softBlue = Color(0xFF42A5F5);
  static const Color softPurple = Color(0xFF9575CD);
  static const Color softPink = Color(0xFFF06292);
  static const Color softOrange = Color(0xFFFF8A65);
  static const Color softTeal = Color(0xFF4DB6AC);
  static const Color softIndigo = Color(0xFF7986CB);
  static const Color vibrantOrange = Color(0xFFFF7043);

  // Surfaces & Backgrounds (Light)
  static const Color backgroundLight = Color(0xFFF5F7F8);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceVariantLight = Color(0xFFEDF0F2);
  static const Color textPrimaryLight = Color(0xFF1A1F1F);
  static const Color textSecondaryLight = Color(0xFF667373);

  // Surfaces & Backgrounds (Dark)
  static const Color backgroundDark = Color(0xFF0F1416);
  static const Color surfaceDark = Color(0xFF162022);
  static const Color surfaceVariantDark = Color(0xFF1E2A2D);
  static const Color textPrimaryDark = Color(0xFFE8EFEE);
  static const Color textSecondaryDark = Color(0xFF9CAEB1);

  // Spacing
  static const double spaceXs = 4.0;
  static const double spaceSm = 8.0;
  static const double spaceMd = 16.0;
  static const double spaceLg = 24.0;
  static const double radiusSm = 12.0;
  static const double radiusMd = 18.0;
  static const double radiusLg = 24.0;
  static const double radiusXl = 32.0;

  // Storage Keys
  static const String lastReadSurahKey = 'last_read_surah';
  static const String lastReadAyahKey = 'last_read_ayah';
  static const String lastReadPageKey = 'last_read_page';
  static const String lastReadJuzKey = 'last_read_juz';
  static const String bookmarksKey = 'bookmarks';
  // Fonts
  static const String uthmaniFont = 'Uthmani';
  static const String urduFont = 'Urdu';
  static const String kitabFont = 'Kitab';
}
