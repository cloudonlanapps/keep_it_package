import 'dart:developer' as dev;

import 'package:cl_basic_types/viewer_types.dart';
import 'package:cl_media_viewer/cl_media_viewer.dart';
import 'package:colan_widgets/colan_widgets.dart'
    show CLErrorView, CLLoadingView, GreyShimmer, SvgIcon, SvgIcons;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../cl_media_viewer.dart' show ImageDataWrapper;
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
    this.imageDataWrapper,
    super.key,
  });

  final Future<void> Function()? onLoadMore;

  /// Optional wrapper for providing image data with faces.
  final ImageDataWrapper? imageDataWrapper;

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
          1 => _buildSingleItemView(currentItem, controls),
          _ => MediaViewerPageView(
            playerControls: controls,
            onLoadMore: onLoadMore,
            imageDataWrapper: imageDataWrapper,
          ),
        };
      },
    );
  }

  Widget _buildSingleItemView(
    ViewerEntity currentItem,
    VideoPlayerControls controls,
  ) {
    // For images with imageDataWrapper, wrap with the data provider
    if (imageDataWrapper != null &&
        currentItem.mediaType == CLMediaType.image) {
      return imageDataWrapper!(
        currentItem,
        (imageData) => ViewMedia(
          currentItem: currentItem,
          autoStart: true,
          playerControls: controls,
          imageData: imageData,
        ),
      );
    }

    // Default: no face data
    return ViewMedia(
      currentItem: currentItem,
      autoStart: true,
      playerControls: controls,
    );
  }
}

class ViewMedia extends ConsumerWidget {
  const ViewMedia({
    required this.currentItem,
    required this.playerControls,
    this.imageData,
    this.autoStart = false,
    super.key,
  });

  final ViewerEntity currentItem;
  final VideoPlayerControls playerControls;
  final bool autoStart;

  /// Optional image data with faces.
  /// If provided, faces will be displayed on the image.
  final InteractiveImageData? imageData;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stateManager = ref.watch(mediaViewerUIStateProvider);
    final uri = currentItem.mediaUri!;
    final isPlayable =
        autoStart &&
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
      '  hasFaces: ${imageData?.faces.isNotEmpty ?? false}\n'
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
      imageData: imageData,
      onLockPage: ({required bool lock}) {},
      isLocked: false,
      autoStart: autoStart,
      autoPlay: true,
      errorBuilder: (_, _) => const CLErrorView.image(),
      loadingBuilder: () => const CLLoadingView.custom(child: GreyShimmer()),
      keepAspectRatio: stateManager.showMenu || isPlayable,
      hasGesture: !stateManager.showMenu,
    );

    if (!isPlayable) {
      return GestureDetector(
        onTap: ref.read(mediaViewerUIStateProvider.notifier).toggleMenu,
        child: Container(
          decoration: BoxDecoration(),
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
