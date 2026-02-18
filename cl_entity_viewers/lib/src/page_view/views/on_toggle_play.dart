import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../builders/get_uri_play_status.dart';
import '../providers/ui_state.dart';
import '../providers/video_player_state.dart';
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
            return Consumer(
              builder: (context, ref, child) {
                final isLoading = ref.watch(videoPlayerProvider).isLoading;
                final isPlaying = playStatus?.isPlaying ?? false;
                final isBuffering = playStatus?.isBuffering ?? false;

                return ShadButton.ghost(
                  onPressed: (isBuffering || isLoading)
                      ? null
                      : () {
                          ref
                              .read(mediaViewerUIStateProvider.notifier)
                              .showPlayerMenu();
                          playerControls?.onPlayPause(
                            uri,
                            autoPlay: false,
                            forced: true,
                          );
                        },
                  child: (isBuffering || isLoading)
                      ? SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: ShadTheme.of(context).colorScheme.background,
                          ),
                        )
                      : Icon(
                          isPlaying ? clIcons.playerPause : clIcons.playerPlay,
                          color: ShadTheme.of(context).colorScheme.background,
                        ),
                );
              },
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
