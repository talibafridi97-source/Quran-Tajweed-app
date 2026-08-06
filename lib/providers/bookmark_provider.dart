import 'package:flutter/material.dart';
import '../services/local_storage_service.dart';

class BookmarkProvider with ChangeNotifier {
  final LocalStorageService _storageService;
  List<int> _bookmarks = [];

  BookmarkProvider(this._storageService) {
    _bookmarks = _storageService.getBookmarks();
  }

  List<int> get bookmarks => _bookmarks;

  void toggleBookmark(int ayahNumber) {
    if (_bookmarks.contains(ayahNumber)) {
      _bookmarks.remove(ayahNumber);
    } else {
      _bookmarks.add(ayahNumber);
    }
    _storageService.saveBookmarks(_bookmarks);
    notifyListeners();
  }

  bool isBookmarked(int ayahNumber) => _bookmarks.contains(ayahNumber);
}
