import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

enum AudioChannel { quran, dua, name }

class AudioManagerService extends ChangeNotifier {
  static final AudioManagerService _instance = AudioManagerService._internal();

  factory AudioManagerService() => _instance;

  static AudioManagerService get instance => _instance;

  AudioManagerService._internal() {
    _audioPlayer.playerStateStream.listen((state) {
      _processingState = state.processingState;
      if (state.processingState == ProcessingState.completed) {
        _isPlaying = false;
        _currentChannel = null;
        _currentAudioId = null;
        _currentAudioUrl = null;
      } else {
        _isPlaying = state.playing;
      }
      notifyListeners();
    });
  }

  final AudioPlayer _audioPlayer = AudioPlayer();

  AudioChannel? _currentChannel;
  String? _currentAudioId;
  String? _currentAudioUrl;
  bool _isPlaying = false;
  bool _isLoading = false;
  String? _errorMessage;
  ProcessingState _processingState = ProcessingState.idle;

  AudioChannel? get currentChannel => _currentChannel;
  String? get currentAudioId => _currentAudioId;
  String? get currentAudioUrl => _currentAudioUrl;
  bool get isPlaying => _isPlaying;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  ProcessingState get processingState => _processingState;
  AudioPlayer get player => _audioPlayer;

  Future<void> playItem({
    required AudioChannel channel,
    required String id,
    required String url,
    String? fallbackUrl,
  }) async {
    // If same item is tapped while playing or paused
    if (_currentChannel == channel && _currentAudioId == id) {
      if (_isPlaying) {
        await pause();
      } else {
        await resume();
      }
      return;
    }

    // Step 1: Stop previous audio & clear state immediately
    await stop();

    _currentChannel = channel;
    _currentAudioId = id;
    _currentAudioUrl = url;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Step 2: Load new item audio
      await _audioPlayer.setUrl(url);
      // Step 3: Play new item
      await _audioPlayer.play();
    } catch (e) {
      if (fallbackUrl != null && fallbackUrl.isNotEmpty) {
        try {
          await _audioPlayer.setUrl(fallbackUrl);
          await _audioPlayer.play();
        } catch (err) {
          _errorMessage = 'Unable to play audio: $err';
        }
      } else {
        _errorMessage = 'Unable to play audio: $e';
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> pause() async {
    await _audioPlayer.pause();
    _isPlaying = false;
    notifyListeners();
  }

  Future<void> resume() async {
    if (_processingState == ProcessingState.completed) {
      await _audioPlayer.seek(Duration.zero);
    }
    await _audioPlayer.play();
    _isPlaying = true;
    notifyListeners();
  }

  Future<void> stop() async {
    await _audioPlayer.stop();
    _currentChannel = null;
    _currentAudioId = null;
    _currentAudioUrl = null;
    _isPlaying = false;
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }

  bool isItemPlaying(AudioChannel channel, String id) {
    return _currentChannel == channel &&
        _currentAudioId == id &&
        _isPlaying &&
        _processingState != ProcessingState.completed;
  }

  bool isItemLoading(AudioChannel channel, String id) {
    return _currentChannel == channel && _currentAudioId == id && _isLoading;
  }
}
