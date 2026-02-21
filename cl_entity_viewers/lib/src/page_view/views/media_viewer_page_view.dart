import 'package:cl_basic_types/viewer_types.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/video_player_controls.dart';
import '../providers/ui_state.dart' show mediaViewerUIStateProvider;
import 'media_viewer_core.dart' show ViewMedia;

class MediaViewerPageView extends ConsumerStatefulWidget {
  const MediaViewerPageView({
    required this.playerControls,
    this.onLoadMore,
    this.faceOverlayBuilder,
    super.key,
  });

  final VideoPlayerControls playerControls;
  final Future<void> Function()? onLoadMore;

  /// Optional builder for face overlay.
  final Widget Function(ViewerEntity entity)? faceOverlayBuilder;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _MediaViewerPageViewState();
}

class _MediaViewerPageViewState extends ConsumerState<MediaViewerPageView> {
  late final PageController pageController;

  @override
  void initState() {
    final currentIndex = ref.read(
      mediaViewerUIStateProvider.select((e) => e.currentIndex),
    );
    pageController = PageController(initialPage: currentIndex);

    super.initState();
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(mediaViewerUIStateProvider);

    return PageView.builder(
      physics: s.showMenu ? null : NeverScrollableScrollPhysics(),
      controller: pageController,
      itemCount: s.entities.length,
      onPageChanged: (index) {
        ref.read(mediaViewerUIStateProvider.notifier).currIndex = index;
        if (widget.onLoadMore != null) {
          // Load more when within 5 items of the end
          if (index >= s.entities.length - 5) {
            widget.onLoadMore?.call();
          }
        }
      },
      itemBuilder: (context, index) {
        final entity = s.entities.entities[index];
        final mediaWidget = ViewMedia(
          currentItem: entity,
          autoStart: index == s.currentIndex,
          playerControls: widget.playerControls,
        );

        // Add face overlay for images if builder is provided
        if (widget.faceOverlayBuilder != null &&
            entity.mediaType == CLMediaType.image) {
          return Stack(
            children: [
              mediaWidget,
              Positioned.fill(child: widget.faceOverlayBuilder!(entity)),
            ],
          );
        }

        return mediaWidget;
      },
    );
  }
}
