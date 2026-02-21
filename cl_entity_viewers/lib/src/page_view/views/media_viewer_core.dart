import 'dart:developer' as dev;

import 'package:cl_basic_types/viewer_types.dart';

import 'package:colan_widgets/colan_widgets.dart'
    show CLErrorView, CLLoadingView, GreyShimmer, SvgIcon, SvgIcons;

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
  const MediaViewerCore({
    this.onLoadMore,
    this.faceOverlayBuilder,
    super.key,
  });

  final Future<void> Function()? onLoadMore;

  /// Optional builder for face overlay.
  final Widget Function(ViewerEntity entity)? faceOverlayBuilder;

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
        final mediaContent = switch (length) {
          0 => Container(),
          1 => ViewMedia(
            currentItem: currentItem,
            autoStart: true,
            playerControls: controls,
          ),
          _ => MediaViewerPageView(
            playerControls: controls,
            onLoadMore: onLoadMore,
            faceOverlayBuilder: faceOverlayBuilder,
          ),
        };

        // For single item, add face overlay on top if provided
        if (length == 1 &&
            faceOverlayBuilder != null &&
            currentItem.mediaType == CLMediaType.image) {
          return Stack(
            children: [
              mediaContent,
              Positioned.fill(child: faceOverlayBuilder!(currentItem)),
            ],
          );
        }

        return mediaContent;
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

    // Debug logging to verify which entity's image is being displayed
    dev.log(
      '========== ViewMedia ==========\n'
      '  ENTITY ID: ${currentItem.id}\n'
      '  mediaUri: $uri\n'
      '  previewUri: ${currentItem.previewUri}\n'
      '  dimensions: ${currentItem.width}x${currentItem.height}\n'
      '  mimeType: ${currentItem.mimeType}\n'
      '  autoStart: $autoStart\n'
      '================================',
      name: 'MediaViewer',
    );

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
      errorBuilder: (_, _) => const CLErrorView.image(),
      loadingBuilder: () => const CLLoadingView.custom(child: GreyShimmer()),
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
          // Note: Do NOT wrap mediaViewer in Center - ExtendedImage with
          // BoxFit.contain already handles centering. Adding Center causes
          // double-centering which breaks face overlay positioning.
          child: mediaViewer,
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
          // Note: Do NOT wrap mediaViewer in Center - ExtendedImage with
          // BoxFit.contain already handles centering. Adding Center causes
          // double-centering which breaks face overlay positioning.
          GestureDetector(
            onTap: () {
              ref.read(mediaViewerUIStateProvider.notifier).showPlayerMenu();
              playerControls.onPlayPause(uri);
            },
            child: mediaViewer,
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
