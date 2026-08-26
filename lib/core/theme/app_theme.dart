import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/constants.dart';

enum AppThemePalette {
  emerald('Default Islamic', 'Emerald & Gold', Color(0xFF0D4D4D), Color(0xFFC9A227)),
  oledDark('OLED Dark', 'Pure Pitch Black', Color(0xFF000000), Color(0xFF00D2D3)),
  creamPaper('Cream Paper', 'Warm Sepia Parchment', Color(0xFF556B2F), Color(0xFFD4AF37)),
  royalGreen('Royal Forest', 'Deep Evergreen Jade', Color(0xFF06281E), Color(0xFF10B981)),
  midnightBlue('Midnight Blue', 'Deep Sapphire Azure', Color(0xFF0A192F), Color(0xFF1E88E5)),
  highContrast('High Contrast', 'Accessible Monochrome', Color(0xFF000000), Color(0xFFFFD700));

  final String displayName;
  final String description;
  final Color primaryPreview;
  final Color accentPreview;

  const AppThemePalette(
    this.displayName,
    this.description,
    this.primaryPreview,
    this.accentPreview,
  );
}

class AppTheme {
  static ThemeData getTheme({
    AppThemePalette palette = AppThemePalette.emerald,
    Brightness brightness = Brightness.light,
  }) {
    final isDark = brightness == Brightness.dark || palette == AppThemePalette.oledDark;

    ColorScheme colorScheme;
    Color scaffoldBg;
    Color surfaceColor;
    Color textColor;

    switch (palette) {
      case AppThemePalette.oledDark:
        scaffoldBg = const Color(0xFF000000);
        surfaceColor = const Color(0xFF121212);
        textColor = const Color(0xFFF1F5F9);
        colorScheme = ColorScheme.dark(
          primary: const Color(0xFF10B981),
          onPrimary: Colors.black,
          secondary: const Color(0xFF00D2D3),
          onSecondary: Colors.black,
          tertiary: const Color(0xFFFFD700),
          surface: surfaceColor,
          onSurface: textColor,
          error: AppConstants.danger,
          outline: const Color(0xFF27272A),
        );
        break;

      case AppThemePalette.creamPaper:
        if (isDark) {
          scaffoldBg = const Color(0xFF1C1917);
          surfaceColor = const Color(0xFF292524);
          textColor = const Color(0xFFF5F5F4);
          colorScheme = ColorScheme.dark(
            primary: const Color(0xFFD4AF37),
            onPrimary: Colors.black,
            secondary: const Color(0xFF84CC16),
            onSecondary: Colors.black,
            tertiary: const Color(0xFFE2B714),
            surface: surfaceColor,
            onSurface: textColor,
            outline: const Color(0xFF44403C),
          );
        } else {
          scaffoldBg = const Color(0xFFFDFBF7);
          surfaceColor = const Color(0xFFF4ECD8);
          textColor = const Color(0xFF2B2520);
          colorScheme = ColorScheme.light(
            primary: const Color(0xFF556B2F),
            onPrimary: Colors.white,
            secondary: const Color(0xFF708238),
            onSecondary: Colors.white,
            tertiary: const Color(0xFFC5A059),
            surface: surfaceColor,
            onSurface: textColor,
            outline: const Color(0xFFE6DCBE),
          );
        }
        break;

      case AppThemePalette.royalGreen:
        if (isDark) {
          scaffoldBg = const Color(0xFF041812);
          surfaceColor = const Color(0xFF092920);
          textColor = const Color(0xFFECFDF5);
          colorScheme = ColorScheme.dark(
            primary: const Color(0xFF10B981),
            onPrimary: Colors.black,
            secondary: const Color(0xFF34D399),
            onSecondary: Colors.black,
            tertiary: const Color(0xFFFBBF24),
            surface: surfaceColor,
            onSurface: textColor,
            outline: const Color(0xFF134E3F),
          );
        } else {
          scaffoldBg = const Color(0xFFF0FDF4);
          surfaceColor = Colors.white;
          textColor = const Color(0xFF064E3B);
          colorScheme = ColorScheme.light(
            primary: const Color(0xFF046A38),
            onPrimary: Colors.white,
            secondary: const Color(0xFF059669),
            onSecondary: Colors.white,
            tertiary: const Color(0xFFD97706),
            surface: surfaceColor,
            onSurface: textColor,
            outline: const Color(0xFFA7F3D0),
          );
        }
        break;

      case AppThemePalette.midnightBlue:
        if (isDark) {
          scaffoldBg = const Color(0xFF0A192F);
          surfaceColor = const Color(0xFF112240);
          textColor = const Color(0xFFCCD6F6);
          colorScheme = ColorScheme.dark(
            primary: const Color(0xFF64FFDA),
            onPrimary: const Color(0xFF0A192F),
            secondary: const Color(0xFF00D2D3),
            onSecondary: Colors.black,
            tertiary: const Color(0xFFFFD166),
            surface: surfaceColor,
            onSurface: textColor,
            outline: const Color(0xFF233554),
          );
        } else {
          scaffoldBg = const Color(0xFFF0F7FF);
          surfaceColor = Colors.white;
          textColor = const Color(0xFF0F172A);
          colorScheme = ColorScheme.light(
            primary: const Color(0xFF1E40AF),
            onPrimary: Colors.white,
            secondary: const Color(0xFF0284C7),
            onSecondary: Colors.white,
            tertiary: const Color(0xFFF59E0B),
            surface: surfaceColor,
            onSurface: textColor,
            outline: const Color(0xFFBAE6FD),
          );
        }
        break;

      case AppThemePalette.highContrast:
        if (isDark) {
          scaffoldBg = Colors.black;
          surfaceColor = const Color(0xFF1A1A1A);
          textColor = Colors.white;
          colorScheme = const ColorScheme.dark(
            primary: Color(0xFFFFD700),
            onPrimary: Colors.black,
            secondary: Colors.white,
            onSecondary: Colors.black,
            tertiary: Color(0xFFFFD700),
            surface: Color(0xFF1A1A1A),
            onSurface: Colors.white,
            outline: Colors.white,
          );
        } else {
          scaffoldBg = Colors.white;
          surfaceColor = const Color(0xFFF8F9FA);
          textColor = Colors.black;
          colorScheme = const ColorScheme.light(
            primary: Colors.black,
            onPrimary: Colors.white,
            secondary: Color(0xFF1E293B),
            onSecondary: Colors.white,
            tertiary: Color(0xFFB45309),
            surface: Color(0xFFF8F9FA),
            onSurface: Colors.black,
            outline: Colors.black,
          );
        }
        break;

      case AppThemePalette.emerald:
      default:
        if (isDark) {
          scaffoldBg = AppConstants.backgroundDark;
          surfaceColor = AppConstants.surfaceDark;
          textColor = AppConstants.textPrimaryDark;
          colorScheme = ColorScheme.fromSeed(
            seedColor: AppConstants.primaryGreen,
            primary: AppConstants.accentMint,
            onPrimary: Colors.black,
            secondary: AppConstants.accentMint,
            onSecondary: Colors.black,
            tertiary: AppConstants.gold,
            surface: surfaceColor,
            onSurface: textColor,
            error: AppConstants.danger,
            outline: AppConstants.surfaceVariantDark,
            brightness: Brightness.dark,
          );
        } else {
          scaffoldBg = AppConstants.backgroundLight;
          surfaceColor = AppConstants.surfaceLight;
          textColor = AppConstants.textPrimaryLight;
          colorScheme = ColorScheme.fromSeed(
            seedColor: AppConstants.primaryGreen,
            primary: AppConstants.primaryGreen,
            onPrimary: Colors.white,
            secondary: AppConstants.accentMint,
            onSecondary: Colors.white,
            tertiary: AppConstants.gold,
            surface: surfaceColor,
            onSurface: textColor,
            error: AppConstants.danger,
            outline: AppConstants.surfaceVariantLight,
            brightness: Brightness.light,
          );
        }
        break;
    }

    final baseTextTheme = isDark ? ThemeData.dark().textTheme : ThemeData.light().textTheme;
    final isTest = !kIsWeb && Platform.environment.containsKey('FLUTTER_TEST');
    TextTheme textTheme = isTest
        ? baseTextTheme
        : GoogleFonts.plusJakartaSansTextTheme(baseTextTheme);

    textTheme = textTheme.copyWith(
      headlineMedium: TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.w800,
        color: colorScheme.onSurface,
        letterSpacing: -0.5,
      ),
      headlineSmall: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w800,
        color: colorScheme.onSurface,
      ),
      titleLarge: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: colorScheme.onSurface,
      ),
      bodyLarge: TextStyle(
        fontSize: 15,
        color: colorScheme.onSurface,
        height: 1.5,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: colorScheme.onSurface.withValues(alpha: 0.85),
        height: 1.5,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: isDark ? Brightness.dark : Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: scaffoldBg,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: colorScheme.primary),
        titleTextStyle: textTheme.headlineSmall?.copyWith(color: colorScheme.primary),
      ),
      cardTheme: CardThemeData(
        color: colorScheme.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? const Color(0xFF1E2A2D) : Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colorScheme.outline.withValues(alpha: 0.2)),
        ),
      ),
    );
  }

  static ThemeData get lightTheme => getTheme(palette: AppThemePalette.emerald, brightness: Brightness.light);
  static ThemeData get darkTheme => getTheme(palette: AppThemePalette.emerald, brightness: Brightness.dark);

  static const LinearGradient brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppConstants.primaryGreen, Color(0xFF007A72)],
  );

  static const LinearGradient brandGradientDeep = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppConstants.deepGreen, AppConstants.primaryGreen],
  );
}
