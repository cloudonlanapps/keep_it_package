import 'package:cl_media_viewer/cl_media_viewer.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cl_basic_types/viewer_types.dart';

import 'providers/ui_state.dart';
import 'views/media_viewer_core.dart';

/// Callback type for building media viewer with face data.
///
/// The [entity] is the current entity being viewed.
/// The [mediaBuilder] should be called with the [InteractiveImageData]
/// that includes any face overlays.
///
/// Example usage in keep_it:
/// ```dart
/// imageDataWrapper: (entity, mediaBuilder) {
///   return GetEntityFaces(
///     entityId: entity.id,
///     builder: (faces) {
///       final imageData = InteractiveImageData(
///         uri: entity.mediaUri!,
///         width: entity.width ?? 1920,
///         height: entity.height ?? 1080,
///         faces: faces.map(_toInteractiveFace).toList(),
///       );
///       return mediaBuilder(imageData);
///     },
///     loadingBuilder: () => mediaBuilder(InteractiveImageData(
///       uri: entity.mediaUri!,
///       width: entity.width ?? 1920,
///       height: entity.height ?? 1080,
///     )),
///   );
/// }
/// ```
typedef ImageDataWrapper = Widget Function(
  ViewerEntity entity,
  Widget Function(InteractiveImageData imageData) mediaBuilder,
);

class CLEntitiesPageView extends ConsumerWidget {
  const CLEntitiesPageView({
    required this.topMenuBuilder,
    required this.bottomMenu,
    this.onLoadMore,
    this.imageDataWrapper,
    super.key,
  });

  final CLTopBar Function(ViewerEntity? entity) topMenuBuilder;
  final PreferredSizeWidget bottomMenu;
  final Future<void> Function()? onLoadMore;

  /// Optional wrapper for providing image data with faces.
  ///
  /// When provided, this wrapper is called for each image entity.
  /// The wrapper should fetch face data asynchronously and call
  /// the [mediaBuilder] with the complete [InteractiveImageData].
  ///
  /// If not provided, images are shown without face overlays.
  final ImageDataWrapper? imageDataWrapper;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showMenu = ref.watch(
      mediaViewerUIStateProvider.select((e) => e.showMenu),
    );
    final currentItem = ref.watch(
      mediaViewerUIStateProvider.select((e) => e.currentItem),
    );
    if (showMenu) {
      return CLScaffold(
        topMenu: topMenuBuilder(currentItem),
        body: SafeArea(
          child: MediaViewerCore(
            onLoadMore: onLoadMore,
            imageDataWrapper: imageDataWrapper,
          ),
        ),
        bottomMenu: bottomMenu,
      );
    } else {
      return CLScaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: MediaViewerCore(
            onLoadMore: onLoadMore,
            imageDataWrapper: imageDataWrapper,
          ),
        ),
      );
    }
  }
}
