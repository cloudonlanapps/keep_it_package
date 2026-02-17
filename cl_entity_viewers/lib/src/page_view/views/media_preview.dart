import 'dart:io';
import 'dart:math' as math;

import 'package:cl_basic_types/viewer_types.dart';

import 'package:colan_widgets/colan_widgets.dart';

import '../../common/views/overlays.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'media_viewer.dart';
import 'media_viewer_overlays.dart';

class MediaPreviewWithOverlays extends StatelessWidget {
  const MediaPreviewWithOverlays({required this.media, super.key});

  final ViewerEntity media;

  @override
  Widget build(BuildContext context) {
    return MediaThumbnail(
      media: media,
      overlays: [
        OverlayWidgets(
          heightFactor: 0.2,
          widthFactor: 0.9,
          alignment: Alignment.bottomCenter,
          fit: BoxFit.none,
          child: Container(
            alignment: Alignment.center,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            color: ShadTheme.of(
              context,
            ).colorScheme.foreground.withValues(alpha: 0.5),
            child: Text(
              media.label ?? 'Unnamed',
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: ShadTheme.of(context).textTheme.small.copyWith(
                color: ShadTheme.of(context).colorScheme.background,
              ),
            ),
          ),
        ),
        if (media.pin != null)
          OverlayWidgets.dimension(
            alignment: Alignment.bottomRight,
            sizeFactor: 0.15,
            child: FutureBuilder(
              future: isPinBroken(media.pin),
              builder: (context, snapshot) {
                return Transform.rotate(
                  angle: math.pi / 4,
                  child: Icon(
                    snapshot.data ?? false ? clIcons.brokenPin : clIcons.pinned,
                    color: snapshot.data ?? false
                        ? Colors.red
                        : const Color.fromARGB(255, 33, 243, 47),
                    size: 32,
                  ),
                );
              },
            ),
          ),
        if (media.mediaType == CLMediaType.video)
          OverlayWidgets.dimension(
            alignment: Alignment.center,
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).colorScheme.onSurface.withAlpha(
                  192,
                ), // Color for the circular container
              ),
              child: Icon(
                clIcons.playerPlay,
                color: CLTheme.of(context).colors.iconColorTransparent,
                size: 32,
              ),
            ),
          ),
      ],
    );
  }
}

class MediaThumbnail extends StatelessWidget {
  const MediaThumbnail({required this.media, this.overlays, super.key});

  final ViewerEntity media;
  final List<OverlayWidgets>? overlays;

  @override
  Widget build(BuildContext context) {
    if (media.previewUri == null) {
      return const BrokenImage();
    }
    if (media.mediaUri!.scheme == 'file') {
      if (!File(media.mediaUri!.toFilePath()).existsSync()) {
        return const BrokenImage();
      }
    }
    try {
      return MediaViewerOverlays(
        uri: media.previewUri!,
        mime: 'image/jpeg',
        overlays: overlays ?? const <OverlayWidgets>[],
        child: MediaViewer(
          heroTag: '/item/${media.id}',
          uri: media.previewUri!,
          mime: 'image/jpeg',
          errorBuilder: (_, _) => const BrokenImage(),
          loadingBuilder: () => const GreyShimmer(),
          fit: BoxFit.cover,
          keepAspectRatio: false,
        ),
      );
    } catch (e) {
      return const BrokenImage();
    }
  }
}

Future<bool> isPinBroken(String? pin) {
  throw UnimplementedError();
}
