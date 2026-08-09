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

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  ResumeData? _resumeData;
  ResumeData? get resumeData => _resumeData;

  QuranProvider(this._repository) {
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    _resumeData = _repository.getResumePoint();
    fetchSurahs();
  }

  Future<void> fetchSurahs() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _surahs = await _repository.getAllSurahs();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
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

  bool getPageReadStatus(int pageNumber) {
    return _repository.getPageReadStatus(pageNumber);
  }

  Future<void> togglePageReadStatus(int pageNumber) async {
    final current = getPageReadStatus(pageNumber);
    await _repository.setPageReadStatus(pageNumber, !current);
    notifyListeners();
  }
}
