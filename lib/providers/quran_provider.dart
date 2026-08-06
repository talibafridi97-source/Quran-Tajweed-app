import 'package:flutter/material.dart';
import '../models/surah.dart';
import '../models/resume_data.dart';
import '../repository/quran_repository.dart';

class QuranProvider with ChangeNotifier {
  final QuranRepository _repository;
  QuranRepository get repository => _repository;
  
  List<Surah> _surahs = [];
  List<Surah> get surahs => _surahs;
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  ResumeData? _resumeData;
  ResumeData? get resumeData => _resumeData;

  QuranProvider(this._repository) {
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    _resumeData = _repository.getResumePoint();
    notifyListeners();
  }

  Future<void> fetchSurahs() async {
    _isLoading = true;
    notifyListeners();
    try {
      _surahs = await _repository.getAllSurahs();
    } catch (e) {
      // Handle error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> saveResume(ResumeData data) async {
    _resumeData = data;
    await _repository.saveResumePoint(data);
    notifyListeners();
  }
}
