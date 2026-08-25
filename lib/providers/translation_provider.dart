import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/translation_model.dart';
import '../repository/quran_repository.dart';

class TranslationProvider with ChangeNotifier {
  final QuranRepository _repository;
  String _selectedEditionId = 'ur.jalandhry';
  bool _isLoading = false;
  Map<int, String> _currentSurahTranslations = {};

  TranslationProvider(this._repository) {
    _loadPreference();
  }

  String get selectedEditionId => _selectedEditionId;
  TranslationEdition get currentEdition => TranslationEdition.findById(_selectedEditionId);
  bool get isLoading => _isLoading;
  Map<int, String> get currentSurahTranslations => _currentSurahTranslations;

  Future<void> _loadPreference() async {
    final prefs = await SharedPreferences.getInstance();
    _selectedEditionId = prefs.getString('selected_translation_edition') ?? 'ur.jalandhry';
    notifyListeners();
  }

  Future<void> setEdition(String editionId, {int? activeSurahNumber}) async {
    _selectedEditionId = editionId;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_translation_edition', editionId);

    if (activeSurahNumber != null) {
      await loadTranslationsForSurah(activeSurahNumber);
    }
  }

  Future<void> loadTranslationsForSurah(int surahNumber) async {
    _isLoading = true;
    notifyListeners();

    try {
      final list = await _repository.getSurahTranslations(
        surahNumber: surahNumber,
        editionId: _selectedEditionId,
      );

      final Map<int, String> map = {};
      for (var t in list) {
        map[t.ayahNumber] = t.text;
      }
      _currentSurahTranslations = map;
    } catch (_) {
      _currentSurahTranslations = {};
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String getTranslationForAyah(int ayahNumber) {
    return _currentSurahTranslations[ayahNumber] ?? '';
  }
}
