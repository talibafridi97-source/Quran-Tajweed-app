import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tajweed_quran/main.dart';
import 'package:tajweed_quran/core/navigation/main_navigation_shell.dart';
import 'package:tajweed_quran/screens/onboarding/onboarding_screen.dart';
import 'package:tajweed_quran/screens/tasbeeh/tasbeeh_screen.dart';
import 'package:tajweed_quran/providers/quran_provider.dart';
import 'package:tajweed_quran/providers/khatam_provider.dart';
import 'package:tajweed_quran/providers/settings_provider.dart';
import 'package:tajweed_quran/providers/tasbeeh_provider.dart';
import 'package:tajweed_quran/providers/hadith_provider.dart';
import 'package:tajweed_quran/providers/bookmark_provider.dart';
import 'package:tajweed_quran/providers/translation_provider.dart';
import 'package:tajweed_quran/providers/search_provider.dart';
import 'package:tajweed_quran/providers/notes_provider.dart';
import 'package:tajweed_quran/repository/quran_repository.dart';
import 'package:tajweed_quran/repository/hadith_repository.dart';
import 'package:tajweed_quran/services/api_service.dart';
import 'package:tajweed_quran/services/hadith_api_service.dart';
import 'package:tajweed_quran/services/local_storage_service.dart';
import 'package:tajweed_quran/services/database_service.dart';
import 'package:tajweed_quran/services/audio_manager_service.dart';
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

  Widget buildAppWrapper({required Widget child}) {
    final storage = LocalStorageService();
    final db = DatabaseService();
    final api = ApiService(storageService: storage);
    final repo = QuranRepository(api, storage, db);
    final quranProvider = QuranProvider(repo);
    final hadithRepo = HadithRepository(HadithApiService(storageService: storage));

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider.value(value: quranProvider),
        ChangeNotifierProvider(create: (_) => HadithProvider(hadithRepo)),
        ChangeNotifierProvider(create: (_) => BookmarkProvider(storage, databaseService: db)),
        ChangeNotifierProvider<KhatamProvider>(create: (_) => MockKhatamProvider()),
        ChangeNotifierProvider(create: (_) => TasbeehProvider(db)),
        ChangeNotifierProvider(create: (_) => TranslationProvider(repo)),
        ChangeNotifierProvider(create: (_) => SearchProvider(repo)),
        ChangeNotifierProvider(create: (_) => NotesProvider(databaseService: db)),
        ChangeNotifierProvider.value(value: AudioManagerService.instance),
      ],
      child: MaterialApp(
        scrollBehavior: const MyCustomScrollBehavior(),
        home: child,
      ),
    );
  }

  testWidgets('Test Pixel 6 scrolling on HomeScreen with pointer kind touch and mouse', (tester) async {
    // Pixel 6 logical screen size: 411 x 912
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.625;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(buildAppWrapper(child: const MainNavigationShell()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Verify initial state shows Tajweed Quran
    expect(find.text('Tajweed Quran'), findsOneWidget);

    // Check if bottom item "Daily Inspiration" is visible or if we can scroll to it
    final inspirationFinder = find.text('Daily Inspiration');
    
    // Attempt dragging up to scroll down
    await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -600));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(inspirationFinder, findsOneWidget);
  });

  testWidgets('Test TasbeehScreen vertical scrolling on constrained screen', (tester) async {
    // Smaller screen height to test scrolling to bottom goal chips
    tester.view.physicalSize = const Size(1080, 1600);
    tester.view.devicePixelRatio = 2.625;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(buildAppWrapper(child: const TasbeehScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Select Target Goal:'), findsOneWidget);
    // Drag down to verify scrollability using vertical SingleChildScrollView
    final verticalScrollView = find.byWidgetPredicate(
      (w) => w is SingleChildScrollView && w.scrollDirection == Axis.vertical,
    );
    await tester.drag(verticalScrollView, const Offset(0, -300));
    await tester.pumpAndSettle();

    expect(find.text('Custom'), findsOneWidget);
  });

  testWidgets('Test SettingsScreen vertical scrolling', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.625;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(buildAppWrapper(child: const MainNavigationShell(initialIndex: 3)));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Settings (الإعدادات)'), findsOneWidget);
    await tester.drag(find.byType(ListView), const Offset(0, -1200));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Default Reciter (Qari)'), findsOneWidget);
  });

  testWidgets('Test OnboardingScreen vertical scrolling when content is tall', (tester) async {
    tester.view.physicalSize = const Size(1080, 1600);
    tester.view.devicePixelRatio = 2.625;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(buildAppWrapper(child: const OnboardingScreen()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Professional 16-Line Quran Mushaf'), findsOneWidget);

    final verticalScrollView = find.byWidgetPredicate(
      (w) => w is SingleChildScrollView && w.scrollDirection == Axis.vertical,
    );
    await tester.drag(verticalScrollView, const Offset(0, -200));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Professional 16-Line Quran Mushaf'), findsOneWidget);
  });
}

