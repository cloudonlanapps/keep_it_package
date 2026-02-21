import 'dart:developer' as dev;
import 'dart:io';

import 'package:cl_basic_types/viewer_types.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/video_player_controls.dart';
import '../providers/image_load_state.dart';
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
  final FocusNode focusNode = FocusNode();

  @override
  void initState() {
    final currentIndex = ref.read(
      mediaViewerUIStateProvider.select((e) => e.currentIndex),
    );
    pageController = PageController(initialPage: currentIndex);

    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    pageController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  void _previousPage() {
    if (pageController.page! > 0) {
      pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _nextPage() {
    final s = ref.read(mediaViewerUIStateProvider);
    if (pageController.page! < s.entities.length - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(mediaViewerUIStateProvider);
    final isDesktop =
        kIsWeb || Platform.isMacOS || Platform.isWindows || Platform.isLinux;

    final pageView = PageView.builder(
      physics: s.showMenu ? null : const NeverScrollableScrollPhysics(),
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

        // Debug: Log which entity is at which index
        dev.log(
          'PageView itemBuilder: index=$index, '
          'entityId=${entity.id}, '
          'dimensions=${entity.width}x${entity.height}',
          name: 'PageViewBuilder',
        );

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
              Positioned.fill(
                child: _FaceOverlayWithLoadCheck(
                  entityId: entity.id!,
                  builder: () => widget.faceOverlayBuilder!(entity),
                ),
              ),
            ],
          );
        }

        return mediaWidget;
      },
    );

    return KeyboardListener(
      focusNode: focusNode,
      autofocus: true,
      onKeyEvent: (event) {
        if (event is KeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
            _previousPage();
          } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
            _nextPage();
          }
        }
      },
      child: Stack(
        children: [
          pageView,
          if (s.showMenu || isDesktop) ...[
            // Previous button
            if (s.currentIndex > 0)
              Positioned(
                left: 16,
                top: 0,
                bottom: 0,
                child: Center(
                  child: IconButton(
                    onPressed: _previousPage,
                    icon: const Icon(
                      Icons.arrow_back_ios,
                      color: Colors.white,
                      shadows: [Shadow(blurRadius: 10, color: Colors.black)],
                    ),
                  ),
                ),
              ),
            // Next button
            if (s.currentIndex < s.entities.length - 1)
              Positioned(
                right: 16,
                top: 0,
                bottom: 0,
                child: Center(
                  child: IconButton(
                    onPressed: _nextPage,
                    icon: const Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.white,
                      shadows: [Shadow(blurRadius: 10, color: Colors.black)],
                    ),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

/// Widget that only shows face overlay after the image has finished loading.
class _FaceOverlayWithLoadCheck extends ConsumerWidget {
  const _FaceOverlayWithLoadCheck({
    required this.entityId,
    required this.builder,
  });

  final int entityId;
  final Widget Function() builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoaded = ref.watch(
      imageLoadStateProvider.select((state) => state[entityId] ?? false),
    );

    if (!isLoaded) {
      return const SizedBox.shrink();
    }

    return builder();
  }
}
