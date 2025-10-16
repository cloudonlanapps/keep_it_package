import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';

import '../models/video_player_controls.dart';
import '../providers/video_player_state.dart';

class GetUriPlayStatus extends ConsumerWidget {
  const GetUriPlayStatus({required this.uri, required this.builder, super.key});
  final Uri uri;
  final Widget Function([
    VideoPlayerControls? playerControls,
    VideoPlayerValue? playStatus,
  ])
  builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uriPlayControlAsync = ref.watch(videoPlayerProvider);
    final playerControls = ref.watch(videoPlayerProvider.notifier);
    return uriPlayControlAsync.when(
      data: (uriPlayControl) {
        if (uriPlayControl.controller == null || uriPlayControl.path != uri) {
          return builder(playerControls);
        }
        return ValueListenableBuilder(
          valueListenable: uriPlayControl.controller!,
          builder: (context, playStatus, child) {
            return builder(playerControls, playStatus);
          },
        );
      },
      error: (_, _) => builder(),
      loading: builder,
    );
  }
}
