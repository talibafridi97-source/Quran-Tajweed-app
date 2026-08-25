import 'package:flutter/material.dart';
import '../models/bookmark_folder_model.dart';
import '../models/bookmark_item_model.dart';
import '../services/database_service.dart';
import '../services/local_storage_service.dart';

class BookmarkProvider with ChangeNotifier {
  final DatabaseService _databaseService;
  final LocalStorageService _storageService;

  List<BookmarkFolder> _folders = [];
  List<BookmarkItem> _bookmarks = [];
  int? _selectedFolderId;
  bool _isLoading = false;

  BookmarkProvider(this._storageService, {DatabaseService? databaseService})
      : _databaseService = databaseService ?? DatabaseService() {
    loadData();
  }

  List<BookmarkFolder> get folders => _folders;
  List<BookmarkItem> get bookmarks => _bookmarks;
  int? get selectedFolderId => _selectedFolderId;
  bool get isLoading => _isLoading;

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    try {
      _folders = await _databaseService.getFolders();
      _bookmarks = await _databaseService.getBookmarks(folderId: _selectedFolderId);
    } catch (_) {} finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void filterByFolder(int? folderId) async {
    _selectedFolderId = folderId;
    _bookmarks = await _databaseService.getBookmarks(folderId: _selectedFolderId);
    notifyListeners();
  }

  Future<void> addBookmark({
    required int surahNumber,
    required int ayahNumber,
    required String surahName,
    required String surahEnglishName,
    required int pageNumber,
    int? folderId,
    String? ayahText,
  }) async {
    final item = BookmarkItem(
      surahNumber: surahNumber,
      ayahNumber: ayahNumber,
      surahName: surahName,
      surahEnglishName: surahEnglishName,
      pageNumber: pageNumber,
      folderId: folderId ?? _folders.firstOrNull?.id,
      ayahText: ayahText,
      createdAt: DateTime.now(),
    );

    await _databaseService.insertBookmark(item);
    await loadData();
  }

  Future<void> removeBookmark(int id) async {
    await _databaseService.deleteBookmark(id);
    await loadData();
  }

  Future<void> removeBookmarkBySurahAyah(int surahNumber, int ayahNumber) async {
    await _databaseService.deleteBookmarkBySurahAyah(surahNumber, ayahNumber);
    await loadData();
  }

  Future<void> toggleBookmark({
    required int surahNumber,
    required int ayahNumber,
    required String surahName,
    required String surahEnglishName,
    required int pageNumber,
    int? folderId,
    String? ayahText,
  }) async {
    final isSaved = isBookmarked(surahNumber, ayahNumber);
    if (isSaved) {
      await removeBookmarkBySurahAyah(surahNumber, ayahNumber);
    } else {
      await addBookmark(
        surahNumber: surahNumber,
        ayahNumber: ayahNumber,
        surahName: surahName,
        surahEnglishName: surahEnglishName,
        pageNumber: pageNumber,
        folderId: folderId,
        ayahText: ayahText,
      );
    }
  }

  bool isBookmarked(int surahNumber, int ayahNumber) {
    return _bookmarks.any((b) => b.surahNumber == surahNumber && b.ayahNumber == ayahNumber);
  }

  // --- Folder Management ---
  Future<void> createFolder(String name, int colorValue) async {
    final folder = BookmarkFolder(
      name: name,
      colorValue: colorValue,
      createdAt: DateTime.now(),
    );
    await _databaseService.insertFolder(folder);
    await loadData();
  }

  Future<void> updateFolder(BookmarkFolder folder) async {
    await _databaseService.updateFolder(folder);
    await loadData();
  }

  Future<void> deleteFolder(int folderId) async {
    await _databaseService.deleteFolder(folderId);
    if (_selectedFolderId == folderId) _selectedFolderId = null;
    await loadData();
  }
}
