import 'package:flutter/material.dart';

class SettingsProvider with ChangeNotifier {
  double _arabicFontSize = 24.0;
  double _translationFontSize = 16.0;
  bool _isDarkMode = false;
  bool _showTranslation = true;
  bool _showTajweed = true;

  double get arabicFontSize => _arabicFontSize;
  double get translationFontSize => _translationFontSize;
  bool get isDarkMode => _isDarkMode;
  bool get showTranslation => _showTranslation;
  bool get showTajweed => _showTajweed;

  void setArabicFontSize(double size) {
    _arabicFontSize = size;
    notifyListeners();
  }

  void toggleDarkMode(bool value) {
    _isDarkMode = value;
    notifyListeners();
  }

  void toggleTranslation(bool value) {
    _showTranslation = value;
    notifyListeners();
  }
}
