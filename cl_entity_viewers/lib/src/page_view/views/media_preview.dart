import 'dart:io';
import 'dart:math' as math;

import 'package:cl_basic_types/viewer_types.dart';

import 'package:colan_widgets/colan_widgets.dart';

import '../../common/views/overlays.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'image_viewer.dart';
import 'media_viewer_overlays.dart';

class MediaPreviewWithOverlays extends StatelessWidget {
  const MediaPreviewWithOverlays({required this.media, super.key});

  final ViewerEntity media;

  @override
  Widget build(BuildContext context) {
    return MediaThumbnail(
      media: media,
      overlays: [
        // Gradient Scrim
        // Gradient Scrim
        OverlayWidgets.scrim(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.7),
                    ],
                  ),
                ),
                alignment: Alignment.bottomCenter,
                padding: const EdgeInsets.only(bottom: 4, left: 8, right: 8),
                child: Text(
                  media.label ?? 'Unnamed',
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: ShadTheme.of(
                    context,
                  ).textTheme.small.copyWith(color: Colors.white),
                ),
              ),
            ],
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
  const MediaThumbnail({
    required this.media,
    this.overlays,
    this.borderRadius = 12,
    super.key,
  });

  final ViewerEntity media;
  final List<OverlayWidgets>? overlays;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    if (media.previewUri == null) {
      return const CLErrorView.image();
    }
    if (media.mediaUri!.scheme == 'file') {
      final fileUri = media.mediaUri!;
      final filePath = fileUri.hasQuery
          ? fileUri.replace(queryParameters: {}).toFilePath()
          : fileUri.toFilePath();
      if (!File(filePath).existsSync()) {
        return const CLErrorView.image();
      }
    }
    try {
      return MediaViewerOverlays(
        uri: media.previewUri!,
        mime: 'image/jpeg',
        overlays: overlays ?? const <OverlayWidgets>[],
        borderRadius: borderRadius,
        child: Hero(
          tag: '/item/${media.id}',
          child: ImageViewer(
            uri: media.previewUri!,
            errorBuilder: (_, _) => const CLErrorView.image(),
            loadingBuilder: () =>
                const CLLoadingView.custom(child: GreyShimmer()),
            onImageLoaded: null,
            fit: BoxFit.cover,
          ),
        ),
      );
    } catch (e) {
      return const CLErrorView.image();
    }
  }
}

Future<bool> isPinBroken(String? pin) {
  throw UnimplementedError();
}
