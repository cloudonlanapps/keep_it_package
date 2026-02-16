import '../../common/views/overlays.dart' show OverlayWidgets;
import 'package:flutter/material.dart';

import 'media_viewer.dart';

class MediaViewerOverlays extends StatelessWidget {
  const MediaViewerOverlays({
    required this.uri,
    required this.child,
    required this.mime,
    required this.overlays,
    super.key,
  });
  final Uri uri;
  final MediaViewer child;
  final String mime;
  final List<OverlayWidgets> overlays;

  @override
  Widget build(BuildContext context) {
    if (overlays.isEmpty) {
      return child;
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Stack(
        children: [
          Positioned.fill(child: child),
          ...overlays,
        ],
      ),
    );
  }
}
