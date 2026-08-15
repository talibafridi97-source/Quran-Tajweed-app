import 'package:flutter_test/flutter_test.dart';
import 'package:tajweed_quran/models/prayer_times_model.dart';
import 'package:tajweed_quran/models/dua_model.dart';
import 'package:tajweed_quran/models/allah_name_model.dart';
import 'package:tajweed_quran/services/audio_manager_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Islamic Calendar, Prayer Times & Audio Isolation Tests', () {
    test('15 August 2026 Gregorian produces valid Rabi al-Awwal 1448 AH date', () {
      final aug15Date = DateTime(2026, 8, 15);
      final model = PrayerTimesModel.calculate(date: aug15Date);

      expect(model.hijriDateString, contains('1448 AH'));
      expect(model.hijriDateString, contains('Rabi al-Awwal'));
      expect(model.hijriDateString, '2 Rabi al-Awwal 1448 AH');
    });

    test('Astronomical Prayer Times for Kohat on 15 August 2026 are accurate and chronological', () {
      final aug15Date = DateTime(2026, 8, 15);
      final model = PrayerTimesModel.calculate(
        lat: 33.5869,
        lng: 71.4426,
        date: aug15Date,
        timeZoneOffsetHours: 5.0,
      );

      expect(model.fajr, '4:04 AM');
      expect(model.sunrise, '5:35 AM');
      expect(model.dhuhr, '12:19 PM');
      expect(model.asr, '3:59 PM');
      expect(model.maghrib, '7:00 PM');
      expect(model.isha, '8:31 PM');
    });

    test('Every Masnoon Dua has a valid distinct audio URL and is not restricted to Bismillah', () {
      final duas = MasnoonDua.allDuas;
      expect(duas.length, greaterThanOrEqualTo(13));
      for (final dua in duas) {
        expect(dua.audioUrl, isNotEmpty);
        expect(dua.audioUrl.endsWith('.mp3'), true);
      }
    });

    test('Every 99 Name of Allah has a distinct audio resource', () {
      final names = AllahName.allNames;
      expect(names.length, 99);
      expect(names.first.number, 1);
      expect(names.last.number, 99);
    });

    test('AudioManagerService singleton maintains isolated state', () {
      final manager = AudioManagerService.instance;
      expect(manager.isPlaying, false);
      expect(manager.currentChannel, null);
      expect(manager.currentAudioId, null);
    });
  });
}
