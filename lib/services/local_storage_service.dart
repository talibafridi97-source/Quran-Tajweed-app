import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/constants.dart';
import '../models/resume_data.dart';

class LocalStorageService {
  static SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> saveResumeData(ResumeData data) async {
    await _prefs?.setString('resume_data', json.encode(data.toJson()));
  }

  ResumeData? getResumeData() {
    final data = _prefs?.getString('resume_data');
    if (data != null) {
      return ResumeData.fromJson(json.decode(data));
    }
    return null;
  }

  Future<void> saveBookmarks(List<int> ayahNumbers) async {
    await _prefs?.setStringList(AppConstants.bookmarksKey, ayahNumbers.map((e) => e.toString()).toList());
  }

  List<int> getBookmarks() {
    final data = _prefs?.getStringList(AppConstants.bookmarksKey);
    return data?.map((e) => int.parse(e)).toList() ?? [];
  }
}
