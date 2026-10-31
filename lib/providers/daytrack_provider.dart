import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../models/activity_category.dart';
import '../models/activity_record.dart';
import '../models/daily_status.dart';
import '../models/routine_template.dart';
import '../services/database_service.dart';
import '../services/time_calculator.dart';
import '../services/score_calculator.dart';
import '../services/period_service.dart';

class DayTrackProvider with ChangeNotifier {
  final DatabaseService _databaseService;

  DayTrackProvider(this._databaseService);

  DateTime _selectedDate = DateTime.now();
  List<ActivityCategory> _categories = [];
  List<ActivityRecord> _selectedDateRecords = [];
  DailyStatus _selectedDateStatus = const DailyStatus(date: '', status: 'in_progress');
  List<RoutineTemplate> _templates = [];
  List<String> _activitySuggestions = [];
  List<ActivityRecord> _recentUniqueActivities = [];
  bool _isLoading = false;

  // Selected period for reports & bottom summary card
  PeriodType _selectedPeriod = PeriodType.today;
  DateTime? _customStartDate;
  DateTime? _customEndDate;
  PeriodReportSummary? _currentReport;

  // Getters
  DateTime get selectedDate => _selectedDate;
  String get selectedDateString => DateFormat('yyyy-MM-dd').format(_selectedDate);
  List<ActivityCategory> get categories => _categories;
  List<ActivityCategory> get activeCategories => _categories.where((c) => !c.isArchived).toList();
  List<ActivityRecord> get selectedDateRecords => _selectedDateRecords;
  DailyStatus get selectedDateStatus => _selectedDateStatus;
  List<RoutineTemplate> get templates => _templates;
  List<String> get activitySuggestions => _activitySuggestions;
  List<ActivityRecord> get recentUniqueActivities => _recentUniqueActivities;
  bool get isLoading => _isLoading;
  PeriodType get selectedPeriod => _selectedPeriod;
  DateTime? get customStartDate => _customStartDate;
  DateTime? get customEndDate => _customEndDate;
  PeriodReportSummary? get currentReport => _currentReport;

  // Computed metrics for currently selected date
  DailyTimeSummary get dailyTimeSummary => TimeCalculator.calculateDailySummary(_selectedDateRecords);
  DayScoreResult get dailyScoreResult => ScoreCalculator.calculateDailyScore(
        categories: _categories,
        records: _selectedDateRecords,
      );

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    await loadCategories();
    await loadTemplates();
    await loadDateData(_selectedDate);
    await loadSuggestions();
    await loadReport();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadCategories() async {
    _categories = await _databaseService.getCategories(includeArchived: true);
    notifyListeners();
  }

  Future<void> loadTemplates() async {
    _templates = await _databaseService.getRoutineTemplates();
    notifyListeners();
  }

  Future<void> loadSuggestions() async {
    _activitySuggestions = await _databaseService.getPastActivityNames(limit: 50);
    _recentUniqueActivities = await _databaseService.getRecentUniqueActivities(limit: 8);
    notifyListeners();
  }

  Future<void> setSelectedDate(DateTime date) async {
    _selectedDate = date;
    await loadDateData(date);
    await loadReport();
  }

  Future<void> loadDateData(DateTime date) async {
    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    _selectedDateRecords = await _databaseService.getRecordsForDate(dateStr);
    _selectedDateStatus = await _databaseService.getDailyStatus(dateStr);
    notifyListeners();
  }

  // --- Category Actions ---
  Future<int> addCategory(ActivityCategory category) async {
    final id = await _databaseService.insertCategory(category);
    await loadCategories();
    await loadReport();
    return id;
  }

  Future<void> updateCategory(ActivityCategory category) async {
    await _databaseService.updateCategory(category);
    await loadCategories();
    await loadReport();
  }

  Future<void> archiveCategory(int id, bool archive) async {
    await _databaseService.archiveCategory(id, archive);
    await loadCategories();
    await loadReport();
  }

  Future<void> deleteCategory(int id) async {
    await _databaseService.deleteCategoryIfUnused(id);
    await loadCategories();
    await loadReport();
  }

  Future<void> saveAutoBalancedWeights() async {
    final balanced = ScoreCalculator.autoBalanceWeights(_categories);
    for (final cat in balanced) {
      if (cat.id != null) {
        await _databaseService.updateCategory(cat);
      }
    }
    await loadCategories();
    await loadReport();
  }

  // --- Activity Record Actions ---
  Future<void> addActivityRecord(ActivityRecord record) async {
    await _databaseService.insertActivityRecord(record);
    await _refreshCurrentDateAndSnapshot();
  }

  Future<void> updateActivityRecord(ActivityRecord record) async {
    await _databaseService.updateActivityRecord(record);
    await _refreshCurrentDateAndSnapshot();
  }

  Future<void> deleteActivityRecord(int id) async {
    await _databaseService.deleteActivityRecord(id);
    await _refreshCurrentDateAndSnapshot();
  }

  Future<void> duplicateActivityRecord(ActivityRecord record) async {
    final now = DateTime.now().toIso8601String();
    final duplicate = record.copyWith(
      id: null,
      createdAt: now,
      updatedAt: now,
    );
    await _databaseService.insertActivityRecord(duplicate);
    await _refreshCurrentDateAndSnapshot();
  }

  Future<void> copyYesterdayEntries() async {
    final yesterday = _selectedDate.subtract(const Duration(days: 1));
    final yesterdayStr = DateFormat('yyyy-MM-dd').format(yesterday);
    await _databaseService.copyRecordsToDate(yesterdayStr, selectedDateString);
    await _refreshCurrentDateAndSnapshot();
  }

  // Split a time block into multiple categories
  Future<void> splitRecord({
    required ActivityRecord original,
    required List<ActivityRecord> newParts,
  }) async {
    if (original.id != null) {
      await _databaseService.deleteActivityRecord(original.id!);
    }
    for (final part in newParts) {
      await _databaseService.insertActivityRecord(part);
    }
    await _refreshCurrentDateAndSnapshot();
  }

  // Mark day as reviewed or reopen
  Future<void> toggleDayReviewed() async {
    final newStatus = _selectedDateStatus.isReviewed ? 'in_progress' : 'reviewed';
    await _databaseService.setDailyStatus(selectedDateString, newStatus);
    _selectedDateStatus = await _databaseService.getDailyStatus(selectedDateString);
    await _refreshCurrentDateAndSnapshot();
  }

  // Routine Templates
  Future<void> applyTemplate(RoutineTemplate template) async {
    final now = DateTime.now().toIso8601String();
    for (final item in template.items) {
      final rec = ActivityRecord(
        date: selectedDateString,
        categoryId: item.categoryId,
        categoryNameSnapshot: item.categoryNameSnapshot,
        activityName: item.activityName,
        durationMinutes: item.durationMinutes,
        startTime: item.startTime,
        endTime: item.endTime,
        status: ActivityStatus.draft,
        createdAt: now,
        updatedAt: now,
      );
      await _databaseService.insertActivityRecord(rec);
    }
    await _refreshCurrentDateAndSnapshot();
  }

  Future<void> saveCurrentDayAsTemplate(String name, String description) async {
    final items = _selectedDateRecords.asMap().entries.map((e) {
      final idx = e.key;
      final r = e.value;
      return RoutineTemplateItem(
        categoryId: r.categoryId,
        categoryNameSnapshot: r.categoryNameSnapshot,
        activityName: r.activityName,
        durationMinutes: r.durationMinutes,
        startTime: r.startTime,
        endTime: r.endTime,
        sortOrder: idx,
      );
    }).toList();

    final template = RoutineTemplate(
      name: name,
      description: description,
      createdAt: DateTime.now().toIso8601String(),
      items: items,
    );
    await _databaseService.insertRoutineTemplate(template);
    await loadTemplates();
  }

  Future<void> deleteTemplate(int templateId) async {
    await _databaseService.deleteRoutineTemplate(templateId);
    await loadTemplates();
  }

  // Period / Reports
  void setPeriod(PeriodType period, {DateTime? customStart, DateTime? customEnd}) {
    _selectedPeriod = period;
    _customStartDate = customStart;
    _customEndDate = customEnd;
    loadReport();
  }

  Future<void> loadReport() async {
    final resolved = PeriodService.resolvePeriodDates(
      _selectedPeriod,
      refDate: _selectedDate,
      customStart: _customStartDate,
      customEnd: _customEndDate,
    );
    final startStr = DateFormat('yyyy-MM-dd').format(resolved.start);
    final endStr = DateFormat('yyyy-MM-dd').format(resolved.end);

    final records = await _databaseService.getRecordsForDateRange(startStr, endStr);
    final reviewedMap = await _databaseService.getReviewedStatusForRange(startStr, endStr);
    final scoreMap = await _databaseService.getHistoricalScoresForRange(startStr, endStr);

    final Map<String, List<ActivityRecord>> recordsByDate = {};
    for (final r in records) {
      recordsByDate.putIfAbsent(r.date, () => []).add(r);
    }

    _currentReport = PeriodService.generateReport(
      periodType: _selectedPeriod,
      startDate: resolved.start,
      endDate: resolved.end,
      categories: _categories,
      recordsByDate: recordsByDate,
      reviewedDaysByDate: reviewedMap,
      historicalScoresByDate: scoreMap,
    );
    notifyListeners();
  }

  Future<void> _refreshCurrentDateAndSnapshot() async {
    await loadDateData(_selectedDate);
    await loadSuggestions();

    // Save historical score snapshot for this day so future settings changes do not silently alter past records
    final scoreResult = dailyScoreResult;
    final snapshotData = {
      'score': scoreResult.totalScore,
      'categories': _categories.where((c) => c.countsForScore).map((c) => {
        'id': c.id,
        'name': c.name,
        'weight': c.weight,
        'target': c.dailyTargetMinutes,
      }).toList(),
    };

    await _databaseService.saveScoreSnapshot(DailyScoreSnapshot(
      date: selectedDateString,
      score: scoreResult.totalScore,
      snapshotJson: jsonEncode(snapshotData),
      createdAt: DateTime.now().toIso8601String(),
    ));

    await loadReport();
  }
}
