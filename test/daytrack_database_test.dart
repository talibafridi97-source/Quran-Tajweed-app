import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:tajweed_quran/services/database_service.dart';
import 'package:tajweed_quran/models/activity_category.dart';
import 'package:tajweed_quran/models/activity_record.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  group('DayTrack 24 Database & Persistence Integration Tests', () {
    late DatabaseService databaseService;

    setUp(() async {
      databaseService = DatabaseService();
    });

    test('Default seed categories are created dynamically', () async {
      final categories = await databaseService.getCategories();
      expect(categories.isNotEmpty, isTrue);
      expect(categories.any((c) => c.name == 'Coding'), isTrue);
      expect(categories.any((c) => c.name == 'Sleep'), isTrue);
    });

    test('Custom category can be inserted and queried', () async {
      final newCat = ActivityCategory(
        name: 'Aerospace Engineering',
        colorValue: 0xFF2563EB,
        iconName: 'school',
        type: CategoryType.productive,
        dailyTargetMinutes: 120,
        weight: 15.0,
        countsForScore: true,
        createdAt: DateTime.now().toIso8601String(),
      );

      final id = await databaseService.insertCategory(newCat);
      expect(id, isPositive);

      final fetched = await databaseService.getCategoryById(id);
      expect(fetched, isNotNull);
      expect(fetched!.name, equals('Aerospace Engineering'));
    });

    test('Archiving category preserves past records and marks archived', () async {
      final cat = await databaseService.insertCategory(ActivityCategory(
        name: 'Guitar Practice',
        colorValue: 0xFF059669,
        iconName: 'music_note',
        type: CategoryType.productive,
        dailyTargetMinutes: 30,
        createdAt: DateTime.now().toIso8601String(),
      ));

      // Add a record for this category
      await databaseService.insertActivityRecord(ActivityRecord(
        date: '2026-10-10',
        categoryId: cat,
        categoryNameSnapshot: 'Guitar Practice',
        activityName: 'Chords',
        durationMinutes: 30,
        createdAt: '',
        updatedAt: '',
      ));

      // Attempt deletion -> triggers safe archive
      await databaseService.deleteCategoryIfUnused(cat);
      final archivedCat = await databaseService.getCategoryById(cat);
      expect(archivedCat!.isArchived, isTrue);

      final records = await databaseService.getRecordsForDate('2026-10-10');
      expect(records.any((r) => r.categoryNameSnapshot == 'Guitar Practice'), isTrue);
    });
  });
}
