import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../../services/audio_manager_service.dart';
import '../constants/constants.dart';

class QuranAudioPlayerWidget extends StatefulWidget {
  final int surahNumber;
  final String surahName;

  const QuranAudioPlayerWidget({
    super.key,
    required this.surahNumber,
    required this.surahName,
  });

  @override
  State<QuranAudioPlayerWidget> createState() => _QuranAudioPlayerWidgetState();
}

class _QuranAudioPlayerWidgetState extends State<QuranAudioPlayerWidget> {
  final _audioManager = AudioManagerService.instance;

  @override
  void initState() {
    super.initState();
    _audioManager.addListener(_onStateChange);
  }

  @override
  void dispose() {
    _audioManager.removeListener(_onStateChange);
    super.dispose();
  }

  void _onStateChange() {
    if (mounted) setState(() {});
  }

  bool get _isThisSurahActive =>
      _audioManager.currentChannel == AudioChannel.quran &&
      _audioManager.currentSurahNumber == widget.surahNumber;

  bool get _isPlaying => _isThisSurahActive && _audioManager.isPlaying;
  bool get _isLoading => _isThisSurahActive && _audioManager.isLoading;

  Future<void> _toggleAudio() async {
    if (_isThisSurahActive) {
      if (_isPlaying) {
        await _audioManager.pause();
      } else {
        await _audioManager.resume();
      }
    } else {
      await _audioManager.playSurah(
        surahNumber: widget.surahNumber,
        surahName: widget.surahName,
      );
    }
  }

  Future<void> _stopAudio() async {
    await _audioManager.stop();
  }

  @override
  Widget build(BuildContext context) {
    final isBuffering = _isThisSurahActive && _audioManager.isLoading;
    final reciterName = (_isThisSurahActive ? _audioManager.currentReciterName : null) ?? 'Mishary Rashid Alafasy';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppConstants.primaryGreen,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppConstants.primaryGreen.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.record_voice_over, color: Colors.white, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Reciter: $reciterName',
                  style: const TextStyle(color: Colors.white70, fontSize: 11),
                ),
                Text(
                  'Surah ${widget.surahName}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),

          if (isBuffering)
            const SizedBox(
              width: 32,
              height: 32,
              child: Padding(
                padding: EdgeInsets.all(4.0),
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
              ),
            )
          else ...[
            if (_isPlaying) ...[
              IconButton(
                icon: const Icon(Icons.pause_circle_filled, color: Colors.white, size: 36),
                onPressed: _toggleAudio,
                tooltip: 'Pause',
              ),
              IconButton(
                icon: const Icon(Icons.stop_circle_rounded, color: Colors.white70, size: 28),
                onPressed: _stopAudio,
                tooltip: 'Stop',
              ),
            ] else ...[
              IconButton(
                icon: const Icon(Icons.play_circle_fill, color: Colors.white, size: 36),
                onPressed: _toggleAudio,
                tooltip: 'Play',
              ),
            ],
          ],
        ],
      ),
    );
  }
}
