import 'dart:async';

import 'package:flutter/material.dart';

import '../models/video_viewer_controller.dart';

/// A widget that displays video playback controls as an overlay.
///
/// Shows play/pause button, seek bar, duration, and volume controls.
/// The controls fade out after a period of inactivity.
class VideoControlsOverlay extends StatefulWidget {
  const VideoControlsOverlay({
    required this.controller,
    this.showVolumeControl = true,
    this.autoHideDuration = const Duration(seconds: 3),
    this.alwaysShow = false,
    super.key,
  });

  /// The video controller to control.
  final VideoViewerController controller;

  /// Whether to show the volume control slider.
  final bool showVolumeControl;

  /// Duration of inactivity before controls auto-hide.
  final Duration autoHideDuration;

  /// If true, controls are always visible.
  final bool alwaysShow;

  @override
  State<VideoControlsOverlay> createState() => _VideoControlsOverlayState();
}

class _VideoControlsOverlayState extends State<VideoControlsOverlay> {
  bool _showControls = true;
  Timer? _hideTimer;
  StreamSubscription<void>? _stateSubscription;

  @override
  void initState() {
    super.initState();
    _stateSubscription = widget.controller.onStateChanged.listen((_) {
      if (mounted) setState(() {});
    });
    _resetHideTimer();
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _stateSubscription?.cancel();
    super.dispose();
  }

  void _resetHideTimer() {
    if (widget.alwaysShow) return;

    _hideTimer?.cancel();
    setState(() => _showControls = true);

    _hideTimer = Timer(widget.autoHideDuration, () {
      if (mounted && widget.controller.isPlaying) {
        setState(() => _showControls = false);
      }
    });
  }

  void _onTap() {
    if (_showControls) {
      _togglePlayPause();
    } else {
      _resetHideTimer();
    }
  }

  Future<void> _togglePlayPause() async {
    if (widget.controller.isPlaying) {
      await widget.controller.pause();
    } else {
      await widget.controller.play();
    }
    _resetHideTimer();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${twoDigits(hours)}:${twoDigits(minutes)}:${twoDigits(seconds)}';
    }
    return '${twoDigits(minutes)}:${twoDigits(seconds)}';
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final showControls = widget.alwaysShow || _showControls;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _onTap,
      child: AnimatedOpacity(
        opacity: showControls ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 300),
        child: IgnorePointer(
          ignoring: !showControls,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.7),
                ],
                stops: const [0.7, 1.0],
              ),
            ),
            child: Stack(
              children: [
                // Center play/pause button
                Center(
                  child: _buildPlayPauseButton(),
                ),

                // Bottom controls
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: _buildBottomControls(controller),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlayPauseButton() {
    final controller = widget.controller;

    if (controller.isBuffering) {
      return const CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
      );
    }

    return IconButton(
      iconSize: 64,
      icon: Icon(
        controller.isPlaying ? Icons.pause_circle : Icons.play_circle,
        color: Colors.white,
      ),
      onPressed: _togglePlayPause,
    );
  }

  Widget _buildBottomControls(VideoViewerController controller) {
    final position = controller.position;
    final duration = controller.duration;
    final progress =
        duration.inMilliseconds > 0
            ? position.inMilliseconds / duration.inMilliseconds
            : 0.0;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Seek bar
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
              activeTrackColor: Colors.white,
              inactiveTrackColor: Colors.white.withValues(alpha: 0.3),
              thumbColor: Colors.white,
              overlayColor: Colors.white.withValues(alpha: 0.3),
            ),
            child: Slider(
              value: progress.clamp(0.0, 1.0),
              onChanged: (value) {
                final newPosition = Duration(
                  milliseconds: (value * duration.inMilliseconds).toInt(),
                );
                controller.seekTo(newPosition);
                _resetHideTimer();
              },
            ),
          ),

          // Duration labels and volume
          Row(
            children: [
              // Current position
              Text(
                _formatDuration(position),
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),

              const Text(
                ' / ',
                style: TextStyle(color: Colors.white54, fontSize: 12),
              ),

              // Total duration
              Text(
                _formatDuration(duration),
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),

              const Spacer(),

              // Volume control
              if (widget.showVolumeControl) ...[
                IconButton(
                  iconSize: 24,
                  icon: Icon(
                    controller.volume == 0
                        ? Icons.volume_off
                        : controller.volume < 0.5
                            ? Icons.volume_down
                            : Icons.volume_up,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    final newVolume = controller.volume > 0 ? 0.0 : 1.0;
                    controller.setVolume(newVolume);
                    _resetHideTimer();
                  },
                ),
                SizedBox(
                  width: 100,
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 2,
                      thumbShape:
                          const RoundSliderThumbShape(enabledThumbRadius: 6),
                      overlayShape:
                          const RoundSliderOverlayShape(overlayRadius: 12),
                      activeTrackColor: Colors.white,
                      inactiveTrackColor: Colors.white.withValues(alpha: 0.3),
                      thumbColor: Colors.white,
                      overlayColor: Colors.white.withValues(alpha: 0.3),
                    ),
                    child: Slider(
                      value: controller.volume,
                      onChanged: (value) {
                        controller.setVolume(value);
                        _resetHideTimer();
                      },
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
