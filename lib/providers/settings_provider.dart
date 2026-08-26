import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/theme/app_theme.dart';

class SettingsProvider with ChangeNotifier {
  double _arabicFontSize = 24.0;
  double _translationFontSize = 16.0;
  double _lineSpacing = 2.0;
  bool _isDarkMode = false;
  AppThemePalette _themePalette = AppThemePalette.emerald;
  String _arabicFontFamily = 'Uthmani';
  bool _showTranslation = true;
  bool _showTajweed = true;
  bool _enableAutoScroll = false;
  double _autoScrollSpeed = 1.0;
  bool _rememberLastPosition = true;
  
  // Audio Preferences
  String _qariId = 'ar.alafasy';
  String _qariName = 'Mishary Rashid Alafasy';
  String _audioRepeatMode = 'none'; // 'none', 'singleAyah', 'surah'
  int _sleepTimerMinutes = 0; // 0 = off

  // Onboarding
  bool _onboardingCompleted = false;

  SettingsProvider() {
    _loadFromPrefs();
  }

  double get arabicFontSize => _arabicFontSize;
  double get translationFontSize => _translationFontSize;
  double get lineSpacing => _lineSpacing;
  bool get isDarkMode => _isDarkMode;
  AppThemePalette get themePalette => _themePalette;
  String get arabicFontFamily => _arabicFontFamily;
  bool get showTranslation => _showTranslation;
  bool get showTajweed => _showTajweed;
  bool get enableAutoScroll => _enableAutoScroll;
  double get autoScrollSpeed => _autoScrollSpeed;
  bool get rememberLastPosition => _rememberLastPosition;
  String get qariId => _qariId;
  String get qariName => _qariName;
  String get audioRepeatMode => _audioRepeatMode;
  int get sleepTimerMinutes => _sleepTimerMinutes;
  bool get onboardingCompleted => _onboardingCompleted;

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _arabicFontSize = prefs.getDouble('arabic_font_size') ?? 24.0;
    _translationFontSize = prefs.getDouble('translation_font_size') ?? 16.0;
    _lineSpacing = prefs.getDouble('line_spacing') ?? 2.0;
    _isDarkMode = prefs.getBool('is_dark_mode') ?? false;
    
    final paletteName = prefs.getString('theme_palette') ?? AppThemePalette.emerald.name;
    _themePalette = AppThemePalette.values.firstWhere(
      (p) => p.name == paletteName,
      orElse: () => AppThemePalette.emerald,
    );

    _arabicFontFamily = prefs.getString('arabic_font_family') ?? 'Uthmani';
    _showTranslation = prefs.getBool('show_translation') ?? true;
    _showTajweed = prefs.getBool('show_tajweed') ?? true;
    _enableAutoScroll = prefs.getBool('enable_auto_scroll') ?? false;
    _autoScrollSpeed = prefs.getDouble('auto_scroll_speed') ?? 1.0;
    _rememberLastPosition = prefs.getBool('remember_last_position') ?? true;

    _qariId = prefs.getString('audio_qari_id') ?? 'ar.alafasy';
    _qariName = prefs.getString('audio_qari_name') ?? 'Mishary Rashid Alafasy';
    _audioRepeatMode = prefs.getString('audio_repeat_mode') ?? 'none';
    _sleepTimerMinutes = prefs.getInt('audio_sleep_timer') ?? 0;
    _onboardingCompleted = prefs.getBool('onboarding_completed') ?? false;

    notifyListeners();
  }

  Future<void> setArabicFontSize(double size) async {
    _arabicFontSize = size;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('arabic_font_size', size);
  }

  Future<void> setTranslationFontSize(double size) async {
    _translationFontSize = size;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('translation_font_size', size);
  }

  Future<void> setLineSpacing(double spacing) async {
    _lineSpacing = spacing;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('line_spacing', spacing);
  }

  Future<void> toggleDarkMode(bool value) async {
    _isDarkMode = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_dark_mode', value);
  }

  Future<void> setThemePalette(AppThemePalette palette) async {
    _themePalette = palette;
    if (palette == AppThemePalette.oledDark) {
      _isDarkMode = true;
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme_palette', palette.name);
    await prefs.setBool('is_dark_mode', _isDarkMode);
  }

  Future<void> setArabicFontFamily(String fontFamily) async {
    _arabicFontFamily = fontFamily;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('arabic_font_family', fontFamily);
  }

  Future<void> toggleTranslation(bool value) async {
    _showTranslation = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('show_translation', value);
  }

  Future<void> toggleTajweed(bool value) async {
    _showTajweed = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('show_tajweed', value);
  }

  Future<void> toggleAutoScroll(bool value) async {
    _enableAutoScroll = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('enable_auto_scroll', value);
  }

  Future<void> setAutoScrollSpeed(double speed) async {
    _autoScrollSpeed = speed;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('auto_scroll_speed', speed);
  }

  Future<void> toggleRememberLastPosition(bool value) async {
    _rememberLastPosition = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('remember_last_position', value);
  }

  Future<void> setQari(String id, String name) async {
    _qariId = id;
    _qariName = name;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('audio_qari_id', id);
    await prefs.setString('audio_qari_name', name);
  }

  Future<void> setAudioRepeatMode(String mode) async {
    _audioRepeatMode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('audio_repeat_mode', mode);
  }

  Future<void> setSleepTimerMinutes(int minutes) async {
    _sleepTimerMinutes = minutes;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('audio_sleep_timer', minutes);
  }

  Future<void> completeOnboarding() async {
    _onboardingCompleted = true;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);
  }
}
