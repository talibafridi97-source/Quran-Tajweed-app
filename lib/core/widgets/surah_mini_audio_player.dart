import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';
import '../../services/audio_manager_service.dart';
import '../constants/constants.dart';

class SurahMiniAudioPlayer extends StatefulWidget {
  final int surahNumber;
  final String surahName;
  final int totalAyahs;

  const SurahMiniAudioPlayer({
    super.key,
    required this.surahNumber,
    required this.surahName,
    required this.totalAyahs,
  });

  @override
  State<SurahMiniAudioPlayer> createState() => _SurahMiniAudioPlayerState();
}

class _SurahMiniAudioPlayerState extends State<SurahMiniAudioPlayer> {
  final AudioManagerService _audioManager = AudioManagerService.instance;
  bool _isDragging = false;
  double _dragPositionMs = 0.0;

  @override
  void initState() {
    super.initState();
    _audioManager.addListener(_onStateChanged);
  }

  @override
  void dispose() {
    _audioManager.removeListener(_onStateChanged);
    super.dispose();
  }

  void _onStateChanged() {
    if (mounted) setState(() {});
  }

  bool get _isThisSurahActive =>
      _audioManager.currentChannel == AudioChannel.quran &&
      _audioManager.currentSurahNumber == widget.surahNumber &&
      !_audioManager.isStopped;

  String _formatDuration(Duration? duration) {
    if (duration == null || duration == Duration.zero) return '00:00';
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    final hours = duration.inHours;
    if (hours > 0) {
      return '$hours:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final isVisible = _isThisSurahActive &&
        (_audioManager.isPlaying || _audioManager.isPaused || _audioManager.isLoading);

    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: isVisible ? _buildPlayerCard(context) : const SizedBox.shrink(),
    );
  }

  Widget _buildPlayerCard(BuildContext context) {
    final currentAyah = _audioManager.currentAyahNumber ?? 1;
    final totalAyahs = _audioManager.totalAyahsInSurah ?? widget.totalAyahs;
    final reciterName = _audioManager.currentReciterName;
    final isPlaying = _audioManager.isPlaying;
    final isLoading = _audioManager.isLoading ||
        _audioManager.processingState == ProcessingState.loading ||
        _audioManager.processingState == ProcessingState.buffering;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F4D3D), Color(0xFF072E24)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppConstants.gold.withValues(alpha: 0.35),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF072E24).withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // TOP INFORMATION
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppConstants.gold.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppConstants.gold.withValues(alpha: 0.4),
                    width: 1,
                  ),
                ),
                child: Text(
                  _audioManager.isBismillah
                      ? 'Bismillah'
                      : 'Ayah $currentAyah of $totalAyahs',
                  style: GoogleFonts.plusJakartaSans(
                    color: AppConstants.gold,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Surah ${widget.surahName}',
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Compact Reciter Badge
              Text(
                reciterName ?? 'Mishary Rashid Alafasy',
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white70,
                  fontSize: 11,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),

          const SizedBox(height: 10),

          // PROGRESS SLIDER & TIMESTAMPS
          StreamBuilder<Duration>(
            stream: _audioManager.positionStream,
            builder: (context, posSnap) {
              final pos = posSnap.data ?? _audioManager.position;
              return StreamBuilder<Duration?>(
                stream: _audioManager.durationStream,
                builder: (context, durSnap) {
                  final total = durSnap.data ?? _audioManager.duration ?? Duration.zero;
                  final maxMs = total.inMilliseconds > 0 ? total.inMilliseconds.toDouble() : 1.0;
                  final currentMs = (_isDragging ? _dragPositionMs : pos.inMilliseconds.toDouble())
                      .clamp(0.0, maxMs);

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 3.5,
                          activeTrackColor: AppConstants.gold,
                          inactiveTrackColor: Colors.white12,
                          thumbColor: Colors.white,
                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6.0),
                          overlayShape: const RoundSliderOverlayShape(overlayRadius: 12.0),
                          overlayColor: AppConstants.gold.withValues(alpha: 0.25),
                        ),
                        child: Slider(
                          value: currentMs,
                          min: 0.0,
                          max: maxMs,
                          onChanged: (val) {
                            setState(() {
                              _isDragging = true;
                              _dragPositionMs = val;
                            });
                          },
                          onChangeEnd: (val) {
                            _audioManager.seek(Duration(milliseconds: val.round()));
                            setState(() {
                              _isDragging = false;
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _formatDuration(_isDragging
                                  ? Duration(milliseconds: _dragPositionMs.round())
                                  : pos),
                              style: const TextStyle(color: Colors.white60, fontSize: 11),
                            ),
                            Text(
                              _formatDuration(total),
                              style: const TextStyle(color: Colors.white60, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),

          const SizedBox(height: 6),

          // MAIN CONTROLS ROW: [ Previous ] [ Play/Pause ] [ Next ] [ Stop ]
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Previous Ayah
              IconButton(
                icon: const Icon(Icons.skip_previous_rounded, color: Colors.white, size: 28),
                onPressed: () => _audioManager.playPreviousAyah(),
                tooltip: 'Previous Ayah',
                padding: const EdgeInsets.all(4),
                constraints: const BoxConstraints(),
              ),

              // Large Central Play / Pause Button
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppConstants.gold,
                  boxShadow: [
                    BoxShadow(
                      color: AppConstants.gold.withValues(alpha: 0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Center(
                  child: isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Color(0xFF072E24),
                            strokeWidth: 2.5,
                          ),
                        )
                      : IconButton(
                          icon: Icon(
                            isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                            color: const Color(0xFF072E24),
                            size: 32,
                          ),
                          onPressed: () {
                            if (isPlaying) {
                              _audioManager.pause();
                            } else {
                              _audioManager.resume();
                            }
                          },
                          tooltip: isPlaying ? 'Pause' : 'Play',
                        ),
                ),
              ),

              // Next Ayah
              IconButton(
                icon: const Icon(Icons.skip_next_rounded, color: Colors.white, size: 28),
                onPressed: () => _audioManager.playNextAyah(),
                tooltip: 'Next Ayah',
                padding: const EdgeInsets.all(4),
                constraints: const BoxConstraints(),
              ),

              // Stop Button
              IconButton(
                icon: const Icon(Icons.stop_circle_outlined, color: Colors.white70, size: 24),
                onPressed: () => _audioManager.stop(),
                tooltip: 'Stop Audio',
                padding: const EdgeInsets.all(4),
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
