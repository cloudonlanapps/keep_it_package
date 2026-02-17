import 'package:cl_basic_types/viewer_types.dart';

import 'package:colan_widgets/colan_widgets.dart'
    show BrokenImage, GreyShimmer, SvgIcon, SvgIcons;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../models/cl_icons.dart';
import '../models/video_player_controls.dart';
import '../builders/get_video_player_controls.dart';
import '../providers/ui_state.dart' show mediaViewerUIStateProvider;
import 'media_viewer.dart';
import 'media_viewer_page_view.dart' show MediaViewerPageView;
import 'on_toggle_audio_mute.dart';
import 'on_toggle_play.dart';
import 'video_progress.dart';

class MediaViewerCore extends ConsumerWidget {
  const MediaViewerCore({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentItem = ref.watch(
      mediaViewerUIStateProvider.select((state) => state.currentItem),
    );
    final length = ref.watch(
      mediaViewerUIStateProvider.select((state) => state.length),
    );

    return GetVideoPlayerControls(
      builder: (controls) {
        return switch (length) {
          0 => Container(),
          1 => ViewMedia(
            currentItem: currentItem,
            autoStart: true,
            playerControls: controls,
          ),
          _ => MediaViewerPageView(playerControls: controls),
        };
      },
    );
  }
}

class ViewMedia extends ConsumerWidget {
  const ViewMedia({
    required this.currentItem,
    required this.playerControls,
    super.key,
    this.autoStart = false,
  });

  final ViewerEntity currentItem;
  final VideoPlayerControls playerControls;
  final bool autoStart;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stateManager = ref.watch(mediaViewerUIStateProvider);
    final uri = currentItem.mediaUri!;
    final isPlayable =
        autoStart &&
        /* widget.playerControls.uri != widget.currentItem.mediaUri && */
        currentItem.mediaType == CLMediaType.video &&
        currentItem.mediaUri != null;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (isPlayable) {
        playerControls.setVideo(uri);
      } else {
        playerControls.removeVideo();
      }
    });

    final mediaViewer = MediaViewer(
      heroTag: '/item/${currentItem.id}',
      uri: currentItem.mediaUri!,
      previewUri: currentItem.previewUri,
      mime: currentItem.mimeType!,
      onLockPage: ({required bool lock}) {},
      isLocked: false,
      autoStart: autoStart,
      autoPlay: true, // Fixme
      errorBuilder: (_, _) => const BrokenImage(),
      loadingBuilder: () => const GreyShimmer(),
      keepAspectRatio: stateManager.showMenu || isPlayable,
      hasGesture: !stateManager.showMenu,
    );
    if (!isPlayable) {
      return GestureDetector(
        onTap: ref.read(mediaViewerUIStateProvider.notifier).toggleMenu,
        // To get the gesture for the entire region, we need
        // this dummy container
        child: Container(
          decoration: BoxDecoration(),
          child: Center(child: mediaViewer),
        ),
      );
    }

    final player = ShadTheme(
      data: ShadTheme.of(context).copyWith(
        textTheme: ShadTheme.of(context).textTheme.copyWith(
          small: ShadTheme.of(context).textTheme.small.copyWith(
            color: playerUIPreferences.foregroundColor,
            fontSize: 10,
          ),
        ),
        ghostButtonTheme: ShadButtonTheme(
          backgroundColor: Colors.black.withValues(alpha: 0.5),
          foregroundColor: Colors.white,
          size: ShadButtonSize.sm,
        ),
      ),
      child: Stack(
        children: [
          if (stateManager.showMenu)
            GestureDetector(
              onTap: () {
                ref.read(mediaViewerUIStateProvider.notifier).showPlayerMenu();
                playerControls.onPlayPause(uri);
              },
              child: mediaViewer,
            )
          else
            Center(
              child: GestureDetector(
                onTap: () {
                  ref
                      .read(mediaViewerUIStateProvider.notifier)
                      .showPlayerMenu();
                  playerControls.onPlayPause(uri);
                },
                child: mediaViewer,
              ),
            ),
          Positioned(
            top: 0,
            right: 0,
            child: ShadButton.ghost(
              onPressed: ref
                  .read(mediaViewerUIStateProvider.notifier)
                  .toggleMenu,
              child: SvgIcon(
                stateManager.showMenu
                    ? SvgIcons.fullScreen
                    : SvgIcons.fullScreenExit,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          if (stateManager.showPlayerMenu) ...[
            Positioned(
              top: 0,
              bottom: 0,
              left: 0,
              right: 0,
              child: OnTogglePlay(uri: currentItem.mediaUri!),
            ),
            Positioned(
              top: 0,
              left: 0,
              child: OnToggleAudioMute(uri: currentItem.mediaUri!),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: VideoProgress(uri: currentItem.mediaUri!),
            ),
          ],
        ],
      ),
    );
    if (stateManager.showMenu) {
      return Center(child: player);
    } else {
      return player;
    }
  }
}
