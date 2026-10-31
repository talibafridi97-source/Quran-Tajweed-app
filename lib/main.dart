import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/routes/app_routes.dart';
import 'providers/quran_provider.dart';
import 'providers/hadith_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/bookmark_provider.dart';
import 'providers/khatam_provider.dart';
import 'providers/tasbeeh_provider.dart';
import 'repository/quran_repository.dart';
import 'repository/hadith_repository.dart';
import 'services/api_service.dart';
import 'services/hadith_api_service.dart';
import 'services/local_storage_service.dart';
import 'services/database_service.dart';
import 'services/audio_manager_service.dart';
import 'providers/translation_provider.dart';
import 'providers/search_provider.dart';
import 'providers/notes_provider.dart';
import 'providers/daytrack_provider.dart';
import 'theme/daytrack_theme.dart';
import 'screens/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final storageService = LocalStorageService();
  await storageService.init();

  final databaseService = DatabaseService();
  
  final apiService = ApiService(storageService: storageService);
  final quranRepository = QuranRepository(apiService, storageService, databaseService);

  final hadithApiService = HadithApiService(storageService: storageService);
  final hadithRepository = HadithRepository(hadithApiService);

  final dayTrackProvider = DayTrackProvider(databaseService);
  await dayTrackProvider.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider.value(value: dayTrackProvider),
        ChangeNotifierProvider(create: (_) => QuranProvider(quranRepository)),
        ChangeNotifierProvider(create: (_) => HadithProvider(hadithRepository)),
        ChangeNotifierProvider(create: (_) => BookmarkProvider(storageService, databaseService: databaseService)),
        ChangeNotifierProvider(create: (_) => KhatamProvider(databaseService)),
        ChangeNotifierProvider(create: (_) => TasbeehProvider(databaseService)),
        ChangeNotifierProvider(create: (_) => TranslationProvider(quranRepository)),
        ChangeNotifierProvider(create: (_) => SearchProvider(quranRepository)),
        ChangeNotifierProvider(create: (_) => NotesProvider(databaseService: databaseService)),
        ChangeNotifierProvider.value(value: AudioManagerService.instance),
      ],
      child: const DayTrack24App(),
    ),
  );
}

class MyCustomScrollBehavior extends MaterialScrollBehavior {
  const MyCustomScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => PointerDeviceKind.values.toSet();

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) =>
      const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics());
}

class DayTrack24App extends StatelessWidget {
  const DayTrack24App({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    
    return MaterialApp(
      title: 'DayTrack 24',
      debugShowCheckedModeBanner: false,
      scrollBehavior: const MyCustomScrollBehavior(),
      theme: DayTrackTheme.lightTheme(),
      darkTheme: DayTrackTheme.darkTheme(),
      themeMode: settings.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: const DashboardScreen(),
      routes: AppRoutes.routes,
    );
  }
}
