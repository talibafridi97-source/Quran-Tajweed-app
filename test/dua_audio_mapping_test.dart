import 'package:flutter_test/flutter_test.dart';
import 'package:tajweed_quran/models/dua_model.dart';
import 'package:tajweed_quran/services/audio_manager_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Masnoon Duas Audio Mapping & Isolation Verification', () {
    test('Every Masnoon Dua has a unique, deterministic ID and valid audio URL', () {
      final Set<String> seenIds = {};
      final Set<int> seenIntIds = {};
      final Set<String> seenUrls = {};

      expect(MasnoonDua.allDuas.length, 13);

      for (final dua in MasnoonDua.allDuas) {
        expect(dua.duaId, isNotEmpty);
        expect(dua.titleEnglish, isNotEmpty);
        expect(dua.arabicText, isNotEmpty);
        expect(dua.audioUrl, startsWith('http'));

        // Verify ID uniqueness
        expect(seenIds.contains(dua.duaId), isFalse, reason: 'Duplicate ID: ${dua.duaId}');
        seenIds.add(dua.duaId);

        expect(seenIntIds.contains(dua.id), isFalse, reason: 'Duplicate int ID: ${dua.id}');
        seenIntIds.add(dua.id);

        // Verify Audio URL uniqueness across all Duas
        expect(seenUrls.contains(dua.audioUrl), isFalse, reason: 'Shared audio URL found for ${dua.duaId}: ${dua.audioUrl}');
        seenUrls.add(dua.audioUrl);
      }
    });

    test('DuaAudioResolver resolves exact Dua and audio URL by ID', () {
      for (final dua in MasnoonDua.allDuas) {
        final resolved = DuaAudioResolver.getDuaById(dua.duaId);
        expect(resolved.id, dua.id);
        expect(resolved.duaId, dua.duaId);
        expect(resolved.titleEnglish, dua.titleEnglish);

        final resolvedUrl = DuaAudioResolver.resolveAudioUrl(dua.duaId);
        expect(resolvedUrl, dua.audioUrl);
      }
    });

    test('DuaAudioResolver throws on invalid Dua ID without fallback to other Duas', () {
      expect(
        () => DuaAudioResolver.getDuaById('invalid_id'),
        throwsA(isA<ArgumentError>()),
      );
      expect(
        () => DuaAudioResolver.resolveAudioUrl('dua_999'),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('validateDuaAudioMapping rejects mismatched cross-over audio URLs', () {
      final dua1 = MasnoonDua.allDuas[0];
      final dua2 = MasnoonDua.allDuas[1];

      // True for own mapping
      expect(DuaAudioResolver.validateDuaAudioMapping(dua1.duaId, dua1.audioUrl), isTrue);
      expect(DuaAudioResolver.validateDuaAudioMapping(dua2.duaId, dua2.audioUrl), isTrue);

      // False when requesting Dua 1 with Dua 2's audio
      expect(DuaAudioResolver.validateDuaAudioMapping(dua1.duaId, dua2.audioUrl), isFalse);
      expect(DuaAudioResolver.validateDuaAudioMapping(dua2.duaId, dua1.audioUrl), isFalse);
    });

    test('AudioManagerService rejects mismatched Dua audio playback and reports error', () async {
      final audioManager = AudioManagerService.instance;
      final dua1 = MasnoonDua.allDuas[0];
      final dua2 = MasnoonDua.allDuas[1];

      // Try playing dua1 with dua2 audio url
      await audioManager.playDua(
        duaId: dua1.duaId,
        audioUrl: dua2.audioUrl,
        title: dua1.titleEnglish,
        subtitle: dua1.titleUrdu,
      );

      expect(audioManager.errorMessage, contains('Audio URL mismatch'));
      expect(audioManager.currentDuaId, isNull);
    });
  });
}
