import 'package:flutter/material.dart';

class AppConstants {
  static const String appName = 'Tajweed Quran';
  static const String baseUrl = 'https://api.alquran.cloud/v1';

  // Brand Colors - Modern Luxury Deep Emerald & Matte Gold
  static const Color primaryGreen = Color(0xFF0D3B2E);
  static const Color deepEmerald = Color(0xFF0A2E23);
  static const Color deepGreen = Color(0xFF07241C);
  static const Color accentGreen = Color(0xFF10B981);
  static const Color gold = Color(0xFFD4AF37);
  static const Color goldMatte = Color(0xFFC5A059);
  static const Color goldLight = Color(0xFFF3E5AB);
  static const Color danger = Color(0xFFE0534E);
  static const Color accentMint = Color(0xFF26A69A);

  // Modern Parchment & Surfaces
  static const Color parchmentLight = Color(0xFFF7F4EB);
  static const Color parchmentWarm = Color(0xFFFCFAF5);

  // Modern Colorful Accent Colors
  static const Color softBlue = Color(0xFF388E3C);
  static const Color softPurple = Color(0xFF8D6E63);
  static const Color softPink = Color(0xFFD81B60);
  static const Color softOrange = Color(0xFFE65100);
  static const Color softTeal = Color(0xFF00897B);
  static const Color softIndigo = Color(0xFF5C6BC0);
  static const Color vibrantOrange = Color(0xFFFF7043);

  // Surfaces & Backgrounds (Light)
  static const Color backgroundLight = Color(0xFFF8F9FA);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceVariantLight = Color(0xFFF0F3F3);
  static const Color textPrimaryLight = Color(0xFF121B18);
  static const Color textSecondaryLight = Color(0xFF5C6B67);

  // Surfaces & Backgrounds (Dark)
  static const Color backgroundDark = Color(0xFF12181B);
  static const Color surfaceDark = Color(0xFF182226);
  static const Color surfaceVariantDark = Color(0xFF202C31);
  static const Color textPrimaryDark = Color(0xFFF0F5F4);
  static const Color textSecondaryDark = Color(0xFF98AAAB);

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
  static const String indoPakFont = 'Scheherazade New'; // Authentic Indo-Pak style
  static const String urduFont = 'Urdu';
  static const String kitabFont = 'Kitab';
}
