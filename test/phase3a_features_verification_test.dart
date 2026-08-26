import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tajweed_quran/models/tajweed_rule_model.dart';
import 'package:tajweed_quran/models/tasbeeh_history_model.dart';
import 'package:tajweed_quran/providers/tasbeeh_provider.dart';
import 'package:tajweed_quran/core/theme/app_theme.dart';
import 'package:tajweed_quran/providers/settings_provider.dart';
import 'package:tajweed_quran/core/utils/tajweed_parser.dart';
import 'package:tajweed_quran/services/database_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Phase 3A.1 — Interactive Tajweed Rules & Waqf Symbols Verification', () {
    test('All Tajweed rules have authentic canonical Quran examples and complete bilingual descriptions', () {
      final rules = TajweedRuleModel.allRules;
      expect(rules.length, greaterThanOrEqualTo(16));

      for (final rule in rules) {
        expect(rule.id, isNotEmpty);
        expect(rule.titleEnglish, isNotEmpty);
        expect(rule.titleArabic, isNotEmpty);
        expect(rule.titleUrdu, isNotEmpty);
        expect(rule.explanationEnglish, isNotEmpty);
        expect(rule.explanationUrdu, isNotEmpty);
        expect(rule.authenticExampleArabic, isNotEmpty);
        expect(rule.surahRef, isNotEmpty);
        expect(rule.ruleColor, isNotNull);

        // Verify Arabic text contains valid Arabic characters
        expect(rule.authenticExampleArabic.contains(RegExp(r'[\u0600-\u06FF]')), true);

        // Verify TajweedParser cleanly parses authentic example without bracket leaks
        final spans = TajweedParser.parse(rule.authenticExampleArabic);
        expect(spans, isNotEmpty);
        for (final span in spans) {
          if (span is TextSpan) {
            final text = span.text ?? '';
            expect(text.contains('['), false, reason: 'Bracket found in ${rule.id}: $text');
            expect(text.contains(']'), false, reason: 'Bracket found in ${rule.id}: $text');
          }
        }
      }
    });

    test('All Waqf stopping signs and symbols are properly cataloged with rules', () {
      final symbols = WaqfSymbolModel.allWaqfSymbols;
      expect(symbols.length, 8);

      final compulsoryStop = symbols.firstWhere((s) => s.symbol == 'مـ');
      expect(compulsoryStop.titleEnglish, contains('Compulsory'));
      expect(compulsoryStop.surahRef, 'Surah Al-An\'am 6:36');

      final sajdah = symbols.firstWhere((s) => s.symbol == '۩');
      expect(sajdah.titleEnglish, contains('Sajdah'));
      expect(sajdah.surahRef, 'Surah Al-\'Alaq 96:19');

      for (final s in symbols) {
        expect(s.symbol, isNotEmpty);
        expect(s.titleArabic, isNotEmpty);
        expect(s.meaning, isNotEmpty);
        expect(s.rule, isNotEmpty);
        expect(s.authenticQuranExample, isNotEmpty);
      }
    });
  });

  group('Phase 3A.2 — Smart Digital Tasbeeh with History & Undo', () {
    test('TasbeehHistoryModel serializes to and from DB map accurately', () {
      final now = DateTime.now();
      final history = TasbeehHistoryModel(
        id: 1,
        dhikrName: 'SubhanAllah',
        arabicText: 'سُبْحَانَ اللَّهِ',
        count: 33,
        target: 33,
        timestamp: now,
      );

      final map = history.toMap();
      final fromDb = TasbeehHistoryModel.fromMap(map);

      expect(fromDb.id, 1);
      expect(fromDb.dhikrName, 'SubhanAllah');
      expect(fromDb.arabicText, 'سُبْحَانَ اللَّهِ');
      expect(fromDb.count, 33);
      expect(fromDb.target, 33);
    });

    test('DhikrItem model serialization and presets', () {
      expect(TasbeehProvider.defaultPresets.length, greaterThanOrEqualTo(8));
      final subhanAllah = TasbeehProvider.defaultPresets.first;
      expect(subhanAllah.title, contains('SubhanAllah'));
      expect(subhanAllah.arabic, 'سُبْحَانَ اللَّهِ');

      final map = subhanAllah.toMap();
      final copy = DhikrItem.fromMap(map);
      expect(copy.title, subhanAllah.title);
      expect(copy.arabic, subhanAllah.arabic);
      expect(copy.defaultTarget, 33);
    });

    test('TasbeehProvider increment, undo, reset, and custom targets', () async {
      final dbService = DatabaseService();
      final provider = TasbeehProvider(dbService);

      expect(provider.counter, 0);
      expect(provider.progress, 0.0);

      // Increment
      provider.increment();
      provider.increment();
      expect(provider.counter, 2);

      // Undo (-1)
      provider.decrement();
      expect(provider.counter, 1);

      // Change target
      provider.setTargetGoal(99);
      expect(provider.targetGoal, 99);

      // Select new Dhikr
      final astaghfirullah = TasbeehProvider.defaultPresets.firstWhere((p) => p.title.contains('Astaghfirullah'));
      provider.selectDhikr(astaghfirullah);
      expect(provider.selectedDua.title, contains('Astaghfirullah'));
      expect(provider.counter, 0);
      expect(provider.targetGoal, 100);

      // Add custom dhikr
      await provider.addCustomDhikr(
        title: 'Custom Salawat',
        arabic: 'اللهم صل على محمد',
        target: 50,
      );
      expect(provider.selectedDua.title, 'Custom Salawat');
      expect(provider.targetGoal, 50);

      // Reset
      provider.increment();
      expect(provider.counter, 1);
      provider.reset();
      expect(provider.counter, 0);
    });
  });

  group('Phase 3A.3 — Multi-Palette Theme Engine & Personalization Settings', () {
    test('All 6 AppThemePalettes generate valid light & dark ThemeData without exceptions', () {
      for (final palette in AppThemePalette.values) {
        final light = AppTheme.getTheme(palette: palette, brightness: Brightness.light);
        final dark = AppTheme.getTheme(palette: palette, brightness: Brightness.dark);

        expect(light, isNotNull);
        expect(dark, isNotNull);
        expect(light.colorScheme.primary, isNotNull);
        expect(dark.colorScheme.primary, isNotNull);
        expect(light.scaffoldBackgroundColor, isNotNull);
        expect(dark.scaffoldBackgroundColor, isNotNull);
      }
    });

    test('SettingsProvider persists theme palette, font family, qari, and sleep timer', () async {
      final settings = SettingsProvider();

      await settings.setThemePalette(AppThemePalette.creamPaper);
      expect(settings.themePalette, AppThemePalette.creamPaper);

      await settings.setArabicFontFamily('QuranAmiri');
      expect(settings.arabicFontFamily, 'QuranAmiri');

      await settings.setQari('ar.sudais', 'Abdur Rahman As-Sudais');
      expect(settings.qariId, 'ar.sudais');
      expect(settings.qariName, 'Abdur Rahman As-Sudais');

      await settings.setSleepTimerMinutes(30);
      expect(settings.sleepTimerMinutes, 30);

      await settings.completeOnboarding();
      expect(settings.onboardingCompleted, true);
    });
  });
}
