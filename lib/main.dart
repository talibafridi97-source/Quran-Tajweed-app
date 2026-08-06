import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/routes/app_routes.dart';
import 'providers/quran_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/bookmark_provider.dart';
import 'repository/quran_repository.dart';
import 'services/api_service.dart';
import 'services/local_storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final storageService = LocalStorageService();
  await storageService.init();
  
  final apiService = ApiService();
  final repository = QuranRepository(apiService, storageService);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => QuranProvider(repository)),
        ChangeNotifierProvider(create: (_) => BookmarkProvider(storageService)),
      ],
      child: const TajweedQuranApp(),
    ),
  );
}

class TajweedQuranApp extends StatelessWidget {
  const TajweedQuranApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    
    return MaterialApp(
      title: 'Tajweed Quran',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: settings.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      initialRoute: AppRoutes.splash,
      routes: AppRoutes.routes,
    );
  }
}
