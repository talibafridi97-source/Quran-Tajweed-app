import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tajweed_quran/services/audio_manager_service.dart';
import 'package:tajweed_quran/core/widgets/reciter_audio_avatar.dart';
import 'package:tajweed_quran/core/widgets/surah_mini_audio_player.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AudioManagerService Ayah & Reciter State Tests', () {
    final audio = AudioManagerService.instance;

    setUp(() async {
      await audio.stop();
    });

    test('Initial state is clean and stopped', () {
      expect(audio.isPlaying, false);
      expect(audio.isPaused, false);
      expect(audio.isStopped, true);
      expect(audio.currentSurahNumber, isNull);
      expect(audio.currentAyahNumber, isNull);
    });

    test('Global Ayah number calculation is mathematically precise', () {
      // Surah 1 (Al-Fatihah, 7 ayahs)
      expect(AudioManagerService.getGlobalAyahNumber(1, 1), 1);
      expect(AudioManagerService.getGlobalAyahNumber(1, 7), 7);

      // Surah 2 (Al-Baqarah, 286 ayahs)
      expect(AudioManagerService.getGlobalAyahNumber(2, 1), 8);
      expect(AudioManagerService.getGlobalAyahNumber(2, 286), 293);

      // Surah 3 (Ali 'Imran, 200 ayahs)
      expect(AudioManagerService.getGlobalAyahNumber(3, 1), 294);

      // Surah 114 (An-Nas, 6 ayahs, total 6236)
      expect(AudioManagerService.getGlobalAyahNumber(114, 1), 6231);
      expect(AudioManagerService.getGlobalAyahNumber(114, 6), 6236);
    });

    test('surahAyahCounts table has exact 114 surahs and 6236 total verses', () {
      expect(AudioManagerService.surahAyahCounts.length, 114);
      final totalVerses = AudioManagerService.surahAyahCounts.reduce((a, b) => a + b);
      expect(totalVerses, 6236);
    });

    test('Stop clears all Ayah and Surah playback state completely', () async {
      // Setup mock state
      await audio.stop();

      expect(audio.currentSurah, isNull);
      expect(audio.currentAyah, isNull);
      expect(audio.currentChannel, isNull);
      expect(audio.currentAudioId, isNull);
      expect(audio.isPlaying, false);
      expect(audio.isStopped, true);
    });

    test('AyahAudioMetadata correctly tags sequence items with metadata', () {
      const meta = AyahAudioMetadata(
        surahNumber: 1,
        ayahNumber: 1,
        surahName: 'Al-Fatihah',
        totalAyahs: 7,
        isBismillah: false,
        title: 'Ayah 1 of 7 • Surah Al-Fatihah',
        subtitle: 'Reciter: Mishary Rashid Alafasy',
      );

      expect(meta.surahNumber, 1);
      expect(meta.ayahNumber, 1);
      expect(meta.surahName, 'Al-Fatihah');
      expect(meta.totalAyahs, 7);
      expect(meta.isBismillah, false);
      expect(meta.title, 'Ayah 1 of 7 • Surah Al-Fatihah');
    });

    test('isAyahPlaying and isAyahActive respond correctly when stopped', () {
      expect(audio.isAyahPlaying(1, 1), false);
      expect(audio.isAyahActive(1, 1), false);
      expect(audio.isItemPlaying(AudioChannel.dua, 'dua_1'), false);
      expect(audio.isItemPlaying(AudioChannel.name, 'name_1'), false);
    });
  });

  group('ReciterAudioAvatar Widget Tests', () {
    testWidgets('Renders static avatar when stopped', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ReciterAudioAvatar(
              isPlaying: false,
              isPaused: false,
              reciterName: 'Mishary Rashid Alafasy',
            ),
          ),
        ),
      );

      expect(find.byType(ReciterAudioAvatar), findsOneWidget);
      expect(find.text('MA'), findsOneWidget); // Mishary Alafasy initials
      // No playing badge
      expect(find.byIcon(Icons.music_note), findsNothing);
    });

    testWidgets('Renders animated progress ring and playing badge when playing', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ReciterAudioAvatar(
              isPlaying: true,
              isPaused: false,
              reciterName: 'Mishary Rashid Alafasy',
            ),
          ),
        ),
      );

      expect(find.byType(ReciterAudioAvatar), findsOneWidget);
      expect(find.text('MA'), findsOneWidget);
      expect(find.byIcon(Icons.music_note), findsOneWidget);
    });

    testWidgets('Renders paused badge and static border when paused', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ReciterAudioAvatar(
              isPlaying: false,
              isPaused: true,
              reciterName: 'Abdul Basit',
            ),
          ),
        ),
      );

      expect(find.byType(ReciterAudioAvatar), findsOneWidget);
      expect(find.text('AB'), findsOneWidget);
      expect(find.byIcon(Icons.pause), findsOneWidget);
    });

    testWidgets('Triggers onTap callback when tapped', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReciterAudioAvatar(
              isPlaying: false,
              isPaused: false,
              reciterName: 'Mishary Rashid Alafasy',
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(ReciterAudioAvatar));
      await tester.pump();
      expect(tapped, true);
    });
  });

  group('SurahMiniAudioPlayer Widget Tests', () {
    testWidgets('Hides completely when audio is stopped', (tester) async {
      await AudioManagerService.instance.stop();

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SurahMiniAudioPlayer(
              surahNumber: 1,
              surahName: 'Al-Fatihah',
              totalAyahs: 7,
            ),
          ),
        ),
      );

      // Should be collapsed/hidden
      expect(find.text('Ayah 1 of 7'), findsNothing);
      expect(find.byIcon(Icons.skip_previous_rounded), findsNothing);
      expect(find.byIcon(Icons.skip_next_rounded), findsNothing);
    });
  });
}
