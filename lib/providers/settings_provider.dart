import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider with ChangeNotifier {
  double _arabicFontSize = 24.0;
  double _translationFontSize = 16.0;
  double _lineSpacing = 2.0;
  bool _isDarkMode = false;
  bool _showTranslation = true;
  bool _showTajweed = true;
  bool _enableAutoScroll = false;
  double _autoScrollSpeed = 1.0; // 1.0 = Slow, 2.0 = Medium, 3.0 = Fast
  bool _rememberLastPosition = true;

  SettingsProvider() {
    _loadFromPrefs();
  }

  double get arabicFontSize => _arabicFontSize;
  double get translationFontSize => _translationFontSize;
  double get lineSpacing => _lineSpacing;
  bool get isDarkMode => _isDarkMode;
  bool get showTranslation => _showTranslation;
  bool get showTajweed => _showTajweed;
  bool get enableAutoScroll => _enableAutoScroll;
  double get autoScrollSpeed => _autoScrollSpeed;
  bool get rememberLastPosition => _rememberLastPosition;

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _arabicFontSize = prefs.getDouble('arabic_font_size') ?? 24.0;
    _translationFontSize = prefs.getDouble('translation_font_size') ?? 16.0;
    _lineSpacing = prefs.getDouble('line_spacing') ?? 2.0;
    _isDarkMode = prefs.getBool('is_dark_mode') ?? false;
    _showTranslation = prefs.getBool('show_translation') ?? true;
    _showTajweed = prefs.getBool('show_tajweed') ?? true;
    _enableAutoScroll = prefs.getBool('enable_auto_scroll') ?? false;
    _autoScrollSpeed = prefs.getDouble('auto_scroll_speed') ?? 1.0;
    _rememberLastPosition = prefs.getBool('remember_last_position') ?? true;
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
}
