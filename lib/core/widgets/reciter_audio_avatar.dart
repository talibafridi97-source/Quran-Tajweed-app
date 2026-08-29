import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../constants/constants.dart';

class ReciterAudioAvatar extends StatefulWidget {
  final bool isPlaying;
  final bool isPaused;
  final bool isLoading;
  final String reciterName;
  final double size;
  final VoidCallback? onTap;

  const ReciterAudioAvatar({
    super.key,
    required this.isPlaying,
    required this.isPaused,
    this.isLoading = false,
    required this.reciterName,
    this.size = 46.0,
    this.onTap,
  });

  @override
  State<ReciterAudioAvatar> createState() => _ReciterAudioAvatarState();
}

class _ReciterAudioAvatarState extends State<ReciterAudioAvatar>
    with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    );

    if (widget.isPlaying) {
      _rotationController.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant ReciterAudioAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isPlaying != oldWidget.isPlaying || widget.isPaused != oldWidget.isPaused) {
      if (widget.isPlaying) {
        if (!_rotationController.isAnimating) {
          _rotationController.repeat();
        }
      } else if (widget.isPaused) {
        // Freeze rotation immediately without jumping or resetting to 0
        if (_rotationController.isAnimating) {
          _rotationController.stop(canceled: false);
        }
      } else {
        // Stopped: reset cleanly
        _rotationController.reset();
      }
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  String _getReciterInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return 'Q';
    if (parts.length == 1) return parts[0].substring(0, math.min(2, parts[0].length)).toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final hasActiveAudio = widget.isPlaying || widget.isPaused;
    final initials = _getReciterInitials(widget.reciterName);

    return InkWell(
      onTap: widget.onTap,
      borderRadius: BorderRadius.circular(widget.size),
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Outer animated progress ring / halo when playing
            if (widget.isPlaying)
              AnimatedBuilder(
                animation: _rotationController,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _rotationController.value * 2 * math.pi,
                    child: Container(
                      width: widget.size,
                      height: widget.size,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const SweepGradient(
                          colors: [
                            AppConstants.gold,
                            Colors.transparent,
                            AppConstants.gold,
                            Colors.transparent,
                            AppConstants.gold,
                          ],
                          stops: [0.0, 0.25, 0.5, 0.75, 1.0],
                        ),
                      ),
                    ),
                  );
                },
              )
            else if (hasActiveAudio)
              // Static gold border when paused
              Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppConstants.gold.withValues(alpha: 0.7),
                    width: 2.0,
                  ),
                ),
              )
            else
              // Elegant subtle ring when stopped
              Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.35),
                    width: 1.5,
                  ),
                ),
              ),

            // Inner Rotating Medallion Avatar
            Padding(
              padding: const EdgeInsets.all(3.0),
              child: AnimatedBuilder(
                animation: _rotationController,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: widget.isPlaying ? (_rotationController.value * 2 * math.pi) : (_rotationController.value * 2 * math.pi),
                    child: child,
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: widget.isPlaying
                          ? [const Color(0xFF0F5A47), const Color(0xFF1B8A6B)]
                          : hasActiveAudio
                              ? [const Color(0xFF1B6B56), const Color(0xFF0D4D3D)]
                              : [const Color(0xFF0A3C30), const Color(0xFF072D24)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.25),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: widget.isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              color: AppConstants.gold,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            initials,
                            style: TextStyle(
                              color: hasActiveAudio ? AppConstants.gold : Colors.white70,
                              fontWeight: FontWeight.bold,
                              fontSize: widget.size * 0.32,
                              letterSpacing: 0.5,
                            ),
                          ),
                  ),
                ),
              ),
            ),

            // Little playback state badge on bottom-right
            if (widget.isPlaying || widget.isPaused)
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 15,
                  height: 15,
                  decoration: BoxDecoration(
                    color: widget.isPlaying ? AppConstants.gold : Colors.grey[700],
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                  child: Center(
                    child: Icon(
                      widget.isPlaying ? Icons.music_note : Icons.pause,
                      size: 8,
                      color: widget.isPlaying ? const Color(0xFF0A3C30) : Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
