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
  late AudioPlayer _audioPlayer;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playAudio() async {
    await AudioManagerService.instance.stop();
    if (_audioPlayer.playerState.processingState == ProcessingState.idle) {
      setState(() => _isLoading = true);
      try {
        final audioUrl = 'https://cdn.islamic.network/quran/audio-surah/128/ar.alafasy/${widget.surahNumber}.mp3';
        await _audioPlayer.setUrl(audioUrl);
        await _audioPlayer.play();
      } catch (e) {
        // Fallback endpoint if primary CDN is unreachable
        try {
          final fallbackUrl = 'https://download.quranicaudio.com/qdc/mishari_al_afasy/murattal/${widget.surahNumber}.mp3';
          await _audioPlayer.setUrl(fallbackUrl);
          await _audioPlayer.play();
        } catch (err) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Audio stream error: $err')),
            );
          }
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    } else {
      await _audioPlayer.play();
    }
  }

  Future<void> _pauseAudio() async {
    await _audioPlayer.pause();
  }

  Future<void> _stopAudio() async {
    await _audioPlayer.stop();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<PlayerState>(
      stream: _audioPlayer.playerStateStream,
      builder: (context, snapshot) {
        final playerState = snapshot.data;
        final processingState = playerState?.processingState;
        final playing = playerState?.playing ?? false;

        final isBuffering = processingState == ProcessingState.loading ||
            processingState == ProcessingState.buffering ||
            _isLoading;

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
                    const Text(
                      'Reciter: Mishary Rashid Alafasy',
                      style: TextStyle(color: Colors.white70, fontSize: 11),
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
                if (playing) ...[
                  IconButton(
                    icon: const Icon(Icons.pause_circle_filled, color: Colors.white, size: 36),
                    onPressed: _pauseAudio,
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
                    onPressed: _playAudio,
                    tooltip: 'Play',
                  ),
                ],
              ],
            ],
          ),
        );
      },
    );
  }
}
