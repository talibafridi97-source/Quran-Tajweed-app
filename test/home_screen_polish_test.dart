import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tajweed_quran/screens/home/home_screen.dart';
import 'package:tajweed_quran/providers/quran_provider.dart';
import 'package:tajweed_quran/providers/khatam_provider.dart';
import 'package:tajweed_quran/providers/settings_provider.dart';
import 'package:tajweed_quran/repository/quran_repository.dart';
import 'package:tajweed_quran/services/api_service.dart';
import 'package:tajweed_quran/services/local_storage_service.dart';
import 'package:tajweed_quran/services/database_service.dart';
import 'package:tajweed_quran/core/theme/app_theme.dart';
import 'package:tajweed_quran/models/resume_data.dart';
import 'package:tajweed_quran/models/khatam_model.dart';

class MockKhatamProvider extends ChangeNotifier implements KhatamProvider {
  @override
  List<KhatamPlan> plans = [];

  @override
  bool isLoading = false;

  @override
  Future<void> addPlan(String title, int days) async {}

  @override
  Future<void> updateProgress(KhatamPlan plan, int surah, int ayah) async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Widget createHomeScreenWrapper({
    ResumeData? resumeData,
    Brightness brightness = Brightness.light,
  }) {
    final storage = LocalStorageService();
    final db = DatabaseService();
    final api = ApiService(storageService: storage);
    final repo = QuranRepository(api, storage, db);
    final quranProvider = QuranProvider(repo);
    if (resumeData != null) {
      quranProvider.saveResume(resumeData);
    }
    final mockKhatam = MockKhatamProvider();
    final settingsProvider = SettingsProvider();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: quranProvider),
        ChangeNotifierProvider<KhatamProvider>.value(value: mockKhatam),
        ChangeNotifierProvider.value(value: settingsProvider),
      ],
      child: MaterialApp(
        theme: AppTheme.getTheme(palette: AppThemePalette.emerald, brightness: brightness),
        home: const HomeScreen(),
      ),
    );
  }

  group('HomeScreen UI/UX Polish Verification', () {
    testWidgets('Renders all primary sections and header actions in Light Mode', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createHomeScreenWrapper());
      await tester.pumpAndSettle();

      // 1. Header checks
      expect(find.text('Tajweed Quran'), findsOneWidget);
      expect(find.byTooltip('Search Quran'), findsOneWidget);
      expect(find.byTooltip('Saved & Notes'), findsOneWidget);
      expect(find.byTooltip('Settings'), findsOneWidget);

      // 2. Last Read Hero Section
      expect(find.text('Start Reading'), findsOneWidget);
      expect(find.text('Surah Al-Fatihah'), findsOneWidget);
      expect(find.text('Open Mushaf'), findsOneWidget);

      // 3. Quran Navigation
      expect(find.text('Explore Quran'), findsOneWidget);
      expect(find.text('114'), findsOneWidget);
      expect(find.text('Surahs'), findsOneWidget);
      expect(find.text('30'), findsOneWidget);
      expect(find.text('Paras'), findsOneWidget);
      expect(find.text('604'), findsOneWidget);
      expect(find.text('Pages'), findsOneWidget);
      expect(find.text('Plan'), findsOneWidget);
      expect(find.text('Khatam'), findsOneWidget);

      // 4. Reading Progress
      expect(find.text('Quran Reading Progress'), findsOneWidget);

      // 5. Islamic Utilities
      expect(find.text('Islamic Utilities'), findsOneWidget);
      expect(find.text('Prayer Times'), findsOneWidget);
      expect(find.text('Qibla Finder'), findsOneWidget);
      expect(find.text('Tasbeeh'), findsOneWidget);
      expect(find.text('Masnoon Duas'), findsOneWidget);
      expect(find.text('99 Names'), findsOneWidget);
      expect(find.text('Hadith Books'), findsOneWidget);

      // 6. Learn & Explore
      expect(find.text('Learn & Explore'), findsOneWidget);
      expect(find.text('Tajweed Rules & Waqf'), findsOneWidget);
      expect(find.text('6 Kalmas of Islam'), findsOneWidget);
      expect(find.text('Hajj & Umrah Guide'), findsOneWidget);
      expect(find.text('Zakat Calculator'), findsOneWidget);

      // 7. Daily Inspiration
      expect(find.text('Daily Inspiration'), findsOneWidget);
    });

    testWidgets('Renders saved resume position dynamically on Hero Card', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final mockResume = ResumeData(
        surahNumber: 2,
        ayahNumber: 255,
        surahName: 'Surah Al-Baqarah',
        page: 42,
        juz: 3,
        lastRead: DateTime.now(),
      );

      await tester.pumpWidget(createHomeScreenWrapper(resumeData: mockResume));
      await tester.pumpAndSettle();

      expect(find.text('Continue Reading'), findsOneWidget);
      expect(find.text('Surah Al-Baqarah'), findsOneWidget);
      expect(find.text('Ayah 255  •  Juz 3  •  Page 42'), findsOneWidget);
      expect(find.text('Resume'), findsOneWidget);
    });

    testWidgets('Renders cleanly in Dark Mode with zero render overflows', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createHomeScreenWrapper(brightness: Brightness.dark));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Tajweed Quran'), findsOneWidget);
    });
  });
}
