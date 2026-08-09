import 'package:flutter/material.dart';
import '../models/hadith_model.dart';
import '../repository/hadith_repository.dart';

class HadithProvider with ChangeNotifier {
  final HadithRepository _repository;
  HadithRepository get repository => _repository;

  List<HadithBook> _books = [];
  List<HadithBook> get books => _books;

  List<HadithChapter> _chapters = [];
  List<HadithChapter> get chapters => _chapters;

  List<HadithItem> _hadiths = [];
  List<HadithItem> get hadiths => _hadiths;

  HadithBook? _selectedBook;
  HadithBook? get selectedBook => _selectedBook;

  HadithChapter? _selectedChapter;
  HadithChapter? get selectedChapter => _selectedChapter;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  HadithProvider(this._repository) {
    _books = _repository.getAvailableBooks();
  }

  Future<void> selectBook(HadithBook book) async {
    _selectedBook = book;
    _chapters = [];
    _hadiths = [];
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _chapters = await _repository.getChaptersForBook(book);
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> selectChapter(HadithBook book, HadithChapter chapter) async {
    _selectedBook = book;
    _selectedChapter = chapter;
    _hadiths = [];
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _hadiths = await _repository.getHadithsForChapter(book: book, chapter: chapter);
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
