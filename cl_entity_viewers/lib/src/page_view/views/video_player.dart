import 'package:cl_media_viewer/cl_media_viewer.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../adapters/video_controller_adapter.dart';
import '../providers/uri_config.dart';
import '../providers/video_player_state.dart';
import 'playback_type_badge.dart';

/// Widget for playing videos using [InteractiveVideoViewer].
///
/// This widget wraps [InteractiveVideoViewer] from cl_media_viewer,
/// using the existing Riverpod-based video player provider for
/// controller lifecycle management.
class VideoPlayer extends ConsumerStatefulWidget {
  const VideoPlayer({
    required this.uri,
    required this.errorBuilder,
    required this.loadingBuilder,
    required this.keepAspectRatio,
    super.key,
  });

  final Uri uri;
  final bool keepAspectRatio;
  final CLErrorView Function(Object, StackTrace) errorBuilder;
  final CLLoadingView Function() loadingBuilder;

  @override
  ConsumerState<VideoPlayer> createState() => _VideoPlayerState();
}

class _VideoPlayerState extends ConsumerState<VideoPlayer> {
  VideoControllerAdapter? _adapter;

  @override
  void dispose() {
    _adapter?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controllerAsync = ref.watch(videoPlayerProvider);
    final uriConfigAsync = ref.watch(uriConfigurationProvider(widget.uri));

    return uriConfigAsync.when(
      data: (uriConfig) => controllerAsync.when(
        data: (playControl) {
          if (playControl.path != widget.uri ||
              playControl.controller == null ||
              !playControl.isInitialized ||
              playControl.isBuffering) {
            return widget.loadingBuilder();
          }

          final controller = playControl.controller!;

          // Create or update the adapter
          if (_adapter == null ||
              _adapter!.videoPlayerController != controller) {
            _adapter?.dispose();
            _adapter = VideoControllerAdapter(
              controller: controller,
              uri: widget.uri,
            );
          }

          return Stack(
            alignment: Alignment.center,
            children: [
              InteractiveVideoViewer(
                controller: _adapter!,
                showControls:
                    false, // Controls managed separately by cl_entity_viewers
                keepAspectRatio: widget.keepAspectRatio,
                quarterTurns: uriConfig.quarterTurns,
              ),
              const Align(
                alignment: Alignment.bottomLeft,
                child: PlaybackTypeBadge(),
              ),
            ],
          );
        },
        error: widget.errorBuilder,
        loading: widget.loadingBuilder,
      ),
      error: widget.errorBuilder,
      loading: widget.loadingBuilder,
    );
  }
}
