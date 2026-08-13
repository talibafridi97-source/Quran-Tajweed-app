import 'package:flutter/material.dart';
import '../models/khatam_model.dart';
import '../services/database_service.dart';

class KhatamProvider with ChangeNotifier {
  final DatabaseService _dbService;
  List<KhatamPlan> _plans = [];
  bool _isLoading = false;

  KhatamProvider(this._dbService) {
    _loadPlans();
  }

  List<KhatamPlan> get plans => _plans;
  bool get isLoading => _isLoading;

  Future<void> _loadPlans() async {
    _isLoading = true;
    notifyListeners();
    _plans = await _dbService.getKhatamPlans();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addPlan(String title, int days) async {
    final newPlan = KhatamPlan(
      id: 0, // Auto-incremented in DB
      title: title,
      startDate: DateTime.now(),
      totalDays: days,
    );
    await _dbService.insertKhatamPlan(newPlan);
    await _loadPlans();
  }

  Future<void> updateProgress(KhatamPlan plan, int surah, int ayah) async {
    final updatedPlan = KhatamPlan(
      id: plan.id,
      title: plan.title,
      startDate: plan.startDate,
      totalDays: plan.totalDays,
      currentSurah: surah,
      currentAyah: ayah,
      isCompleted: surah == 114 && ayah == 6, // Approximate for check
    );
    await _dbService.updateKhatamPlan(updatedPlan);
    await _loadPlans();
  }
}
