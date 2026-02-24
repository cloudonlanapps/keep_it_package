import 'dart:developer' as dev;
import 'dart:io';

import 'package:cl_basic_types/viewer_types.dart';
import 'package:cl_media_viewer/cl_media_viewer.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../cl_media_viewer.dart' show ImageDataWrapper;
import '../models/video_player_controls.dart';
import '../providers/ui_state.dart' show mediaViewerUIStateProvider;
import 'media_viewer_core.dart' show ViewMedia;

class MediaViewerPageView extends ConsumerStatefulWidget {
  const MediaViewerPageView({
    required this.playerControls,
    this.onLoadMore,
    this.imageDataWrapper,
    super.key,
  });

  final VideoPlayerControls playerControls;
  final Future<void> Function()? onLoadMore;

  /// Optional wrapper for providing image data with faces.
  final ImageDataWrapper? imageDataWrapper;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _MediaViewerPageViewState();
}

class _MediaViewerPageViewState extends ConsumerState<MediaViewerPageView> {
  late final PageController pageController;
  final FocusNode focusNode = FocusNode();

  /// Track which images have been precached to avoid redundant calls
  final Set<int> _precachedIndices = {};

  @override
  void initState() {
    final currentIndex = ref.read(
      mediaViewerUIStateProvider.select((e) => e.currentIndex),
    );
    pageController = PageController(initialPage: currentIndex);

    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      focusNode.requestFocus();
      // Precache adjacent images after first frame
      _precacheAdjacentImages(currentIndex);
    });
  }

  @override
  void dispose() {
    pageController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  /// Precache images adjacent to the given index for smoother transitions.
  void _precacheAdjacentImages(int currentIndex) {
    final entities = ref.read(mediaViewerUIStateProvider).entities;
    final indicesToPrecache = <int>[
      currentIndex - 1,
      currentIndex,
      currentIndex + 1,
    ].where((i) => i >= 0 && i < entities.length);

    for (final index in indicesToPrecache) {
      if (_precachedIndices.contains(index)) continue;

      final entity = entities.entities[index];
      if (entity.mediaType != CLMediaType.image) continue;

      final uri = entity.mediaUri;
      if (uri == null) continue;

      _precacheImage(uri);
      _precachedIndices.add(index);
    }
  }

  /// Precache a single image by URI.
  void _precacheImage(Uri uri) {
    if (!mounted) return;

    try {
      ImageProvider? provider;

      if (uri.scheme == 'file') {
        final path = uri.hasQuery
            ? uri.replace(queryParameters: {}).toFilePath()
            : uri.toFilePath();
        provider = ExtendedFileImageProvider(File(path));
      } else if (uri.scheme == 'asset' || uri.scheme.isEmpty) {
        final assetPath = uri.scheme == 'asset' ? uri.path : uri.toString();
        provider = ExtendedAssetImageProvider(assetPath);
      } else if (uri.scheme == 'http' || uri.scheme == 'https') {
        provider = ExtendedNetworkImageProvider(uri.toString(), cache: true);
      }

      if (provider != null) {
        precacheImage(provider, context).then((_) {
          dev.log(
            'Precached image: $uri',
            name: 'ImagePrecache',
          );
        }).catchError((e) {
          dev.log(
            'Failed to precache image: $uri - $e',
            name: 'ImagePrecache',
          );
        });
      }
    } catch (e) {
      dev.log(
        'Error setting up precache for: $uri - $e',
        name: 'ImagePrecache',
      );
    }
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

        // Precache adjacent images for smooth transitions
        _precacheAdjacentImages(index);

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

        return _buildMediaWidget(entity, index == s.currentIndex);
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

  Widget _buildMediaWidget(ViewerEntity entity, bool autoStart) {
    // For images with imageDataWrapper, wrap with the data provider
    if (widget.imageDataWrapper != null &&
        entity.mediaType == CLMediaType.image) {
      return widget.imageDataWrapper!(
        entity,
        (InteractiveImageData imageData) => ViewMedia(
          currentItem: entity,
          autoStart: autoStart,
          playerControls: widget.playerControls,
          imageData: imageData,
        ),
      );
    }

    // Default: no face data
    return ViewMedia(
      currentItem: entity,
      autoStart: autoStart,
      playerControls: widget.playerControls,
    );
  }
}
