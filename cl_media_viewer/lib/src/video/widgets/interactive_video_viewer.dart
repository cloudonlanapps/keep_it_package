import 'dart:async';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../models/video_viewer_controller.dart';
import 'video_controls_overlay.dart';

/// A standalone, self-contained widget for viewing videos.
///
/// This widget:
/// - Displays a video from a URI via the provided controller
/// - Shows optional playback controls (play/pause, seek, volume)
/// - Supports rotation via quarterTurns
/// - Can maintain or ignore aspect ratio
///
/// The widget doesn't manage controller lifecycle - that's the consumer's
/// responsibility. The controller must be initialized before being passed
/// to this widget.
///
/// Example usage:
/// ```dart
/// final controller = DefaultVideoViewerController();
/// await controller.initialize(Uri.parse('asset:assets/video.mp4'));
///
/// InteractiveVideoViewer(
///   controller: controller,
///   showControls: true,
///   onTap: () => print('Video tapped'),
/// )
/// ```
class InteractiveVideoViewer extends StatefulWidget {
  const InteractiveVideoViewer({
    required this.controller,
    this.showControls = true,
    this.keepAspectRatio = true,
    this.quarterTurns = 0,
    this.autoHideControlsDuration = const Duration(seconds: 3),
    this.onTap,
    this.errorBuilder,
    this.loadingBuilder,
    super.key,
  });

  /// The video controller that manages playback.
  /// Must be initialized before being passed to this widget.
  final VideoViewerController controller;

  /// Whether to show playback controls overlay.
  final bool showControls;

  /// Whether to maintain the video's aspect ratio.
  /// If false, the video will stretch to fill the available space.
  final bool keepAspectRatio;

  /// Number of clockwise quarter turns to rotate the video.
  /// 0 = no rotation, 1 = 90°, 2 = 180°, 3 = 270°.
  final int quarterTurns;

  /// Duration of inactivity before controls auto-hide.
  final Duration autoHideControlsDuration;

  /// Called when the video area is tapped.
  /// Note: If showControls is true, tapping toggles play/pause.
  final VoidCallback? onTap;

  /// Builder for error state.
  final Widget Function(Object error)? errorBuilder;

  /// Builder for loading/buffering state.
  final Widget Function()? loadingBuilder;

  @override
  State<InteractiveVideoViewer> createState() => _InteractiveVideoViewerState();
}

class _InteractiveVideoViewerState extends State<InteractiveVideoViewer> {
  StreamSubscription<void>? _stateSubscription;

  @override
  void initState() {
    super.initState();
    _stateSubscription = widget.controller.onStateChanged.listen((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void didUpdateWidget(InteractiveVideoViewer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      _stateSubscription?.cancel();
      _stateSubscription = widget.controller.onStateChanged.listen((_) {
        if (mounted) setState(() {});
      });
    }
  }

  @override
  void dispose() {
    _stateSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;

    // Show loading if not initialized
    if (!controller.isInitialized) {
      return _buildLoading();
    }

    // Get the underlying video_player controller for rendering
    final videoPlayerController = controller.videoPlayerController;
    if (videoPlayerController == null) {
      return _buildLoading();
    }

    // Build the video widget
    Widget videoWidget = VideoPlayer(videoPlayerController);

    // Apply rotation if specified
    if (widget.quarterTurns != 0) {
      videoWidget = RotatedBox(
        quarterTurns: widget.quarterTurns,
        child: videoWidget,
      );
    }

    // Apply aspect ratio if enabled
    if (widget.keepAspectRatio) {
      // Calculate effective aspect ratio considering rotation
      final effectiveAspectRatio =
          widget.quarterTurns.isEven
              ? controller.aspectRatio
              : 1 / controller.aspectRatio;

      videoWidget = AspectRatio(
        aspectRatio: effectiveAspectRatio,
        child: videoWidget,
      );
    }

    // Wrap in a container for controls overlay
    Widget content = Stack(
      fit: StackFit.passthrough,
      children: [
        // Video
        videoWidget,

        // Controls overlay
        if (widget.showControls)
          Positioned.fill(
            child: VideoControlsOverlay(
              controller: controller,
              autoHideDuration: widget.autoHideControlsDuration,
            ),
          ),
      ],
    );

    // Add external tap handler if controls are hidden
    if (!widget.showControls && widget.onTap != null) {
      content = GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: content,
      );
    }

    return content;
  }

  Widget _buildLoading() {
    if (widget.loadingBuilder != null) {
      return widget.loadingBuilder!();
    }
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}
