import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:video_player/video_player.dart' as vplayer;

import '../providers/uri_config.dart';
import '../providers/video_player_state.dart';
import 'playback_type_badge.dart';

class VideoPlayer extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final controllerAsync = ref.watch(videoPlayerProvider);
    final uriConfigAsync = ref.watch(uriConfigurationProvider(uri));

    return uriConfigAsync.when(
      data: (uriConfig) => controllerAsync.when(
        data: (playControl) {
          if (playControl.path != uri ||
              playControl.controller == null ||
              !playControl.isInitialized ||
              playControl.isBuffering) {
            return loadingBuilder();
          }
          final controller = playControl.controller!;
          final videoWidget = keepAspectRatio
              ? AspectRatio(
                  aspectRatio: uriConfig.quarterTurns.isEven
                      ? controller.value.aspectRatio
                      : 1 / controller.value.aspectRatio,
                  child: RotatedBox(
                    quarterTurns: uriConfig.quarterTurns,
                    child: vplayer.VideoPlayer(controller),
                  ),
                )
              : vplayer.VideoPlayer(controller);

          return Stack(
            alignment: Alignment.center,
            children: [
              videoWidget,
              const Align(
                alignment: Alignment.topRight,
                child: PlaybackTypeBadge(),
              ),
            ],
          );
        },
        error: errorBuilder,
        loading: loadingBuilder,
      ),
      error: errorBuilder,
      loading: loadingBuilder,
    );
  }
}
