# Implementation Plan - Tajweed Quran App

Build a professional Quran Tajweed app using Flutter with Clean Architecture, Provider state management, and an Islamic-themed Material 3 UI.

## User Review Required

> [!IMPORTANT]
> The app will rely on the `api.alquran.cloud` for fetching Quranic data. Offline support will be limited to cached data and persistent settings/bookmarks.
> The "Tajweed" text feature requires specific API endpoints that provide tajweed-annotated text (like `quran-tajweed` edition).

## Proposed Changes

### 1. Project Infrastructure

#### [MODIFY] [pubspec.yaml](file:///C:/Users/LENOVO/AndroidStudioProjects/Tajweed_Quran/pubspec.yaml)
- Add dependencies: `provider`, `http`, `shared_preferences`, `google_fonts`, `flutter_spinkit`, `intl`, `just_audio`, `share_plus`, `path_provider`, `logger`.

#### [NEW] Directory Structure
- Create `lib/core/`, `lib/models/`, `lib/repository/`, `lib/providers/`, `lib/services/`, `lib/screens/`, `lib/assets/` and their subdirectories.

### 2. Core Layer

#### [NEW] [constants.dart](file:///C:/Users/LENOVO/AndroidStudioProjects/Tajweed_Quran/lib/core/constants/constants.dart)
- API Base URLs, Color Constants (Primary Islamic Green), and App Strings.

#### [NEW] [app_theme.dart](file:///C:/Users/LENOVO/AndroidStudioProjects/Tajweed_Quran/lib/core/theme/app_theme.dart)
- Material 3 Light/Dark themes with rounded card configurations and Islamic-inspired color palettes.

#### [NEW] [app_routes.dart](file:///C:/Users/LENOVO/AndroidStudioProjects/Tajweed_Quran/lib/core/routes/app_routes.dart)
- Named routes definition for all screens.

### 3. Models & Data Handling

#### [NEW] [surah.dart](file:///C:/Users/LENOVO/AndroidStudioProjects/Tajweed_Quran/lib/models/surah.dart)
#### [NEW] [ayah.dart](file:///C:/Users/LENOVO/AndroidStudioProjects/Tajweed_Quran/lib/models/ayah.dart)
#### [NEW] [juz.dart](file:///C:/Users/LENOVO/AndroidStudioProjects/Tajweed_Quran/lib/models/juz.dart)
#### [NEW] [resume_data.dart](file:///C:/Users/LENOVO/AndroidStudioProjects/Tajweed_Quran/lib/models/resume_data.dart)

### 4. Services & Repository

#### [NEW] [api_service.dart](file:///C:/Users/LENOVO/AndroidStudioProjects/Tajweed_Quran/lib/services/api_service.dart)
- Fetching Surahs, Ayahs (with Tajweed), and Search results.

#### [NEW] [local_storage_service.dart](file:///C:/Users/LENOVO/AndroidStudioProjects/Tajweed_Quran/lib/services/local_storage_service.dart)
- Persistence for Bookmarks, Settings, and Last Read position.

#### [NEW] [quran_repository.dart](file:///C:/Users/LENOVO/AndroidStudioProjects/Tajweed_Quran/lib/repository/quran_repository.dart)
- Abstraction layer between UI and Data services.

### 5. State Management (Providers)

#### [NEW] [quran_provider.dart](file:///C:/Users/LENOVO/AndroidStudioProjects/Tajweed_Quran/lib/providers/quran_provider.dart)
- Main logic for loading Quran content and managing active reading sessions.

#### [NEW] [settings_provider.dart](file:///C:/Users/LENOVO/AndroidStudioProjects/Tajweed_Quran/lib/providers/settings_provider.dart)
- Handles font sizes, translations visibility, and theme switching.

#### [NEW] [bookmark_provider.dart](file:///C:/Users/LENOVO/AndroidStudioProjects/Tajweed_Quran/lib/providers/bookmark_provider.dart)
- Logic for adding/removing bookmarks.

### 6. UI Implementation (Screens)

#### [NEW] [splash_screen.dart](file:///C:/Users/LENOVO/AndroidStudioProjects/Tajweed_Quran/lib/screens/splash/splash_screen.dart)
- Animated intro with Logo and App Name.

#### [NEW] [home_screen.dart](file:///C:/Users/LENOVO/AndroidStudioProjects/Tajweed_Quran/lib/screens/home/home_screen.dart)
- Dashboard featuring Resume Reading card and navigation buttons.

#### [NEW] [surah_list_screen.dart](file:///C:/Users/LENOVO/AndroidStudioProjects/Tajweed_Quran/lib/screens/surah/surah_list_screen.dart)
- List view for all 114 Surahs with metadata.

#### [NEW] [surah_detail_screen.dart](file:///C:/Users/LENOVO/AndroidStudioProjects/Tajweed_Quran/lib/screens/surah/surah_detail_screen.dart)
- Detailed Ayah-by-Ayah view with Tajweed annotations and audio player.

#### [NEW] [settings_screen.dart](file:///C:/Users/LENOVO/AndroidStudioProjects/Tajweed_Quran/lib/screens/settings/settings_screen.dart)
- Comprehensive settings management.

## Verification Plan

### Manual Verification
1. Launch app and verify Splash animation.
2. Navigate to Surah Index and open a Surah.
3. Verify Tajweed text and Translation display.
4. Add a Bookmark and check the Bookmark screen.
5. Change font size in Settings and verify impact on Surah Detail screen.
6. Toggle Dark Mode and verify theme consistency.
7. Restart app and verify "Resume Reading" points to the correct last-read Ayah.
