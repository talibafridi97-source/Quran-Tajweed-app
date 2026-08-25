import 'package:flutter/material.dart';
import '../models/ayah_note_model.dart';
import '../services/database_service.dart';

class NotesProvider with ChangeNotifier {
  final DatabaseService _databaseService;
  List<AyahNote> _notes = [];
  bool _isLoading = false;

  NotesProvider({DatabaseService? databaseService})
      : _databaseService = databaseService ?? DatabaseService() {
    loadNotes();
  }

  List<AyahNote> get notes => _notes;
  bool get isLoading => _isLoading;

  Future<void> loadNotes() async {
    _isLoading = true;
    notifyListeners();

    try {
      _notes = await _databaseService.getNotes();
    } catch (_) {
      _notes = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> saveNote({
    required int surahNumber,
    required int ayahNumber,
    required String surahName,
    required String surahEnglishName,
    required String noteText,
  }) async {
    final existing = await _databaseService.getNoteForAyah(surahNumber, ayahNumber);
    if (existing != null) {
      final updated = existing.copyWith(
        noteText: noteText,
        updatedAt: DateTime.now(),
      );
      await _databaseService.updateNote(updated);
    } else {
      final newNote = AyahNote(
        surahNumber: surahNumber,
        ayahNumber: ayahNumber,
        surahName: surahName,
        surahEnglishName: surahEnglishName,
        noteText: noteText,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await _databaseService.insertNote(newNote);
    }
    await loadNotes();
  }

  Future<void> deleteNote(int id) async {
    await _databaseService.deleteNote(id);
    await loadNotes();
  }

  Future<AyahNote?> getNoteForAyah(int surahNumber, int ayahNumber) async {
    return await _databaseService.getNoteForAyah(surahNumber, ayahNumber);
  }
}
