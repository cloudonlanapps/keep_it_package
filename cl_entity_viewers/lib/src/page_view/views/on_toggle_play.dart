import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../builders/get_uri_play_status.dart';
import 'video_progress.dart' show MenuBackground2;

class OnTogglePlay extends StatelessWidget {
  const OnTogglePlay({required this.uri, super.key});

  final Uri uri;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: MenuBackground2(
        child: GetUriPlayStatus(
          uri: uri,
          builder: ([playerControls, playStatus]) {
            final isPlaying = playStatus?.isPlaying ?? false;

            return ShadButton.ghost(
              onPressed: () => {
                playerControls?.onPlayPause(uri, autoPlay: false, forced: true),
              },
              child: Icon(
                isPlaying ? clIcons.playerPause : clIcons.playerPlay,
                color: ShadTheme.of(context).colorScheme.background,
              ),
            );
          },
        ),
      ),
    );
  }
}

/* class OnTogglePlay2 extends StatelessWidget {
  const OnTogglePlay2({
    required this.uri,
    super.key,
  });

  final Uri uri;

  @override
  Widget build(BuildContext context) {
    return GetUriPlayStatus(
      uri: uri,
      builder: ([playerControls, playStatus]) {
        if (playerControls == null || playStatus == null) {
          return const SizedBox.shrink();
        }
        {
          return CircledIcon(
            playStatus.isPlaying
                ? videoPlayerIcons.playerPause
                : videoPlayerIcons.playerPlay,
            onTap: () => {
              playerControls.onPlayPause(
                autoPlay: false,
                forced: true,
              ),
            },
            color: ShadTheme.of(context).colorScheme.background,
          );
        }
      },
    );
  }
} */
