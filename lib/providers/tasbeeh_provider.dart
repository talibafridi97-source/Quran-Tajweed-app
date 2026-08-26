import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/tasbeeh_history_model.dart';
import '../services/database_service.dart';

class DhikrItem {
  final String title;
  final String arabic;
  final String transliteration;
  final int defaultTarget;

  const DhikrItem({
    required this.title,
    required this.arabic,
    required this.transliteration,
    this.defaultTarget = 33,
  });

  Map<String, dynamic> toMap() => {
        'title': title,
        'arabic': arabic,
        'transliteration': transliteration,
        'defaultTarget': defaultTarget,
      };

  factory DhikrItem.fromMap(Map<String, dynamic> map) => DhikrItem(
        title: map['title'] as String? ?? '',
        arabic: map['arabic'] as String? ?? '',
        transliteration: map['transliteration'] as String? ?? '',
        defaultTarget: map['defaultTarget'] as int? ?? 33,
      );
}

class TasbeehProvider with ChangeNotifier {
  final DatabaseService _databaseService;

  int _counter = 0;
  int _targetGoal = 33;
  int _completedCycles = 0;
  bool _hapticEnabled = true;
  bool _soundEnabled = true;
  DhikrItem _selectedDua = defaultPresets.first;
  List<DhikrItem> _customPresets = [];
  List<TasbeehHistoryModel> _history = [];
  int _totalLifetimeCount = 0;

  static const List<DhikrItem> defaultPresets = [
    DhikrItem(
      title: 'SubhanAllah (سُبْحَانَ اللَّهِ)',
      arabic: 'سُبْحَانَ اللَّهِ',
      transliteration: 'Glory be to Allah',
      defaultTarget: 33,
    ),
    DhikrItem(
      title: 'Alhamdulillah (الْحَمْدُ لِلَّهِ)',
      arabic: 'الْحَمْدُ لِلَّهِ',
      transliteration: 'All praise is due to Allah',
      defaultTarget: 33,
    ),
    DhikrItem(
      title: 'Allahu Akbar (اللَّهُ أَكْبَرُ)',
      arabic: 'اللَّهُ أَكْبَرُ',
      transliteration: 'Allah is the Greatest',
      defaultTarget: 34,
    ),
    DhikrItem(
      title: 'Astaghfirullah (أَسْتَغْفِرُ اللَّهَ)',
      arabic: 'أَسْتَغْفِرُ اللَّهَ',
      transliteration: 'I seek forgiveness from Allah',
      defaultTarget: 100,
    ),
    DhikrItem(
      title: 'La ilaha illallah (لَا إِلٰهَ إِلَّا اللَّهُ)',
      arabic: 'لَا إِلٰهَ إِلَّا اللَّهُ',
      transliteration: 'There is no god but Allah',
      defaultTarget: 100,
    ),
    DhikrItem(
      title: 'Salawat on the Prophet (ﷺ)',
      arabic: 'اللَّهُمَّ صَلِّ عَلَىٰ مُحَمَّدٍ وَعَلَىٰ آلِ مُحَمَّدٍ',
      transliteration: 'O Allah, send blessings upon Muhammad and his family',
      defaultTarget: 100,
    ),
    DhikrItem(
      title: 'Hasbunallahu wa ni\'mal wakeel',
      arabic: 'حَسْبُنَا اللَّهُ وَنِعْمَ الْوَكِيلُ',
      transliteration: 'Allah is sufficient for us and He is the best disposer of affairs',
      defaultTarget: 100,
    ),
    DhikrItem(
      title: 'SubhanAllahi wa bihamdihi',
      arabic: 'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ سُبْحَانَ اللَّهِ الْعَظِيمِ',
      transliteration: 'Glory be to Allah and His is the praise, Glory be to Allah the Supreme',
      defaultTarget: 100,
    ),
    DhikrItem(
      title: 'Ayat al-Kursi Dhikr',
      arabic: 'لَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ الْعَلِيِّ الْعَظِيمِ',
      transliteration: 'There is no power nor strength except through Allah',
      defaultTarget: 100,
    ),
  ];

  TasbeehProvider(this._databaseService) {
    _loadState();
  }

  int get counter => _counter;
  int get targetGoal => _targetGoal;
  int get completedCycles => _completedCycles;
  bool get hapticEnabled => _hapticEnabled;
  bool get soundEnabled => _soundEnabled;
  DhikrItem get selectedDua => _selectedDua;
  List<DhikrItem> get allPresets => [...defaultPresets, ..._customPresets];
  List<TasbeehHistoryModel> get history => _history;
  int get totalLifetimeCount => _totalLifetimeCount;
  double get progress => _targetGoal > 0 ? (_counter / _targetGoal).clamp(0.0, 1.0) : 0.0;

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    _counter = prefs.getInt('tasbeeh_counter_v3') ?? 0;
    _targetGoal = prefs.getInt('tasbeeh_goal_v3') ?? 33;
    _completedCycles = prefs.getInt('tasbeeh_completed_cycles') ?? 0;
    _hapticEnabled = prefs.getBool('tasbeeh_haptic') ?? true;
    _soundEnabled = prefs.getBool('tasbeeh_sound') ?? true;

    final customDhikrsJson = prefs.getStringList('tasbeeh_custom_presets') ?? [];
    _customPresets = customDhikrsJson
        .map((j) => DhikrItem.fromMap(json.decode(j) as Map<String, dynamic>))
        .toList();

    final selectedTitle = prefs.getString('tasbeeh_selected_title');
    if (selectedTitle != null) {
      final found = allPresets.where((p) => p.title == selectedTitle);
      if (found.isNotEmpty) {
        _selectedDua = found.first;
      }
    }

    await loadHistory();
    notifyListeners();
  }

  Future<void> _saveState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('tasbeeh_counter_v3', _counter);
    await prefs.setInt('tasbeeh_goal_v3', _targetGoal);
    await prefs.setInt('tasbeeh_completed_cycles', _completedCycles);
    await prefs.setBool('tasbeeh_haptic', _hapticEnabled);
    await prefs.setBool('tasbeeh_sound', _soundEnabled);
    await prefs.setString('tasbeeh_selected_title', _selectedDua.title);
  }

  Future<void> loadHistory() async {
    try {
      _history = await _databaseService.getTasbeehHistory(limit: 100);
      _totalLifetimeCount = await _databaseService.getTotalTasbeehCount();
      notifyListeners();
    } catch (_) {}
  }

  void increment() {
    _counter++;
    if (_hapticEnabled) {
      if (_counter == _targetGoal) {
        HapticFeedback.heavyImpact();
      } else {
        HapticFeedback.lightImpact();
      }
    }
    if (_soundEnabled) {
      SystemSound.play(SystemSoundType.click);
    }

    // Check if reached target
    if (_counter >= _targetGoal && _targetGoal > 0) {
      _completedCycles++;
      _recordCompletedSession(_targetGoal);
    }

    _saveState();
    notifyListeners();
  }

  void decrement() {
    if (_counter > 0) {
      _counter--;
      if (_hapticEnabled) {
        HapticFeedback.selectionClick();
      }
      _saveState();
      notifyListeners();
    }
  }

  void reset() {
    if (_counter > 0) {
      _recordCompletedSession(_counter);
    }
    _counter = 0;
    _saveState();
    notifyListeners();
  }

  void setTargetGoal(int goal) {
    if (goal > 0) {
      _targetGoal = goal;
      _saveState();
      notifyListeners();
    }
  }

  void selectDhikr(DhikrItem item) {
    if (_counter > 0) {
      _recordCompletedSession(_counter);
    }
    _selectedDua = item;
    _counter = 0;
    _targetGoal = item.defaultTarget;
    _saveState();
    notifyListeners();
  }

  Future<void> addCustomDhikr({
    required String title,
    required String arabic,
    String transliteration = '',
    int target = 33,
  }) async {
    final newItem = DhikrItem(
      title: title,
      arabic: arabic,
      transliteration: transliteration,
      defaultTarget: target,
    );
    _customPresets.add(newItem);

    final prefs = await SharedPreferences.getInstance();
    final jsonList = _customPresets.map((p) => json.encode(p.toMap())).toList();
    await prefs.setStringList('tasbeeh_custom_presets', jsonList);

    selectDhikr(newItem);
  }

  void toggleHaptic(bool val) {
    _hapticEnabled = val;
    _saveState();
    notifyListeners();
  }

  void toggleSound(bool val) {
    _soundEnabled = val;
    _saveState();
    notifyListeners();
  }

  Future<void> _recordCompletedSession(int count) async {
    if (count <= 0) return;
    try {
      final session = TasbeehHistoryModel(
        dhikrName: _selectedDua.title,
        arabicText: _selectedDua.arabic,
        count: count,
        target: _targetGoal,
        timestamp: DateTime.now(),
      );
      await _databaseService.insertTasbeehHistory(session);
      await loadHistory();
    } catch (_) {}
  }

  Future<void> clearHistory() async {
    try {
      await _databaseService.clearTasbeehHistory();
      await loadHistory();
    } catch (_) {}
  }
}
