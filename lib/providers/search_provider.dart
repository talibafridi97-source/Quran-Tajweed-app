import 'package:flutter/material.dart';
import '../repository/quran_repository.dart';

class QuranSearchResult {
  final int surahNumber;
  final int ayahNumber;
  final String surahName;
  final String surahEnglishName;
  final String canonicalArabic;
  final String translationText;

  const QuranSearchResult({
    required this.surahNumber,
    required this.ayahNumber,
    required this.surahName,
    required this.surahEnglishName,
    required this.canonicalArabic,
    this.translationText = '',
  });
}

class SearchProvider with ChangeNotifier {
  final QuranRepository _repository;
  String _query = '';
  bool _isLoading = false;
  List<QuranSearchResult> _results = [];
  String? _errorMessage;

  SearchProvider(this._repository);

  String get query => _query;
  bool get isLoading => _isLoading;
  List<QuranSearchResult> get results => _results;
  String? get errorMessage => _errorMessage;

  Future<void> search(String query) async {
    _query = query.trim();
    if (_query.isEmpty) {
      _results = [];
      _isLoading = false;
      _errorMessage = null;
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final rawResults = await _repository.searchQuran(_query, limit: 100);
      _results = rawResults.map((m) {
        return QuranSearchResult(
          surahNumber: m['surah_number'] as int? ?? 1,
          ayahNumber: m['ayah_number'] as int? ?? 1,
          surahName: m['surah_name'] as String? ?? 'Surah',
          surahEnglishName: m['surah_english_name'] as String? ?? 'Surah',
          canonicalArabic: m['canonical_arabic'] as String? ?? '',
          translationText: m['translation_text'] as String? ?? '',
        );
      }).toList();
    } catch (e) {
      _errorMessage = 'Search error: $e';
      _results = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearSearch() {
    _query = '';
    _results = [];
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }
}
