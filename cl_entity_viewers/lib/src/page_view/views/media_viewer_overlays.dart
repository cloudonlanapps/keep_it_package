import '../../common/views/overlays.dart' show OverlayWidgets;
import 'package:flutter/material.dart';

class MediaViewerOverlays extends StatelessWidget {
  const MediaViewerOverlays({
    required this.uri,
    required this.child,
    required this.mime,
    required this.overlays,
    this.borderRadius = 12,
    super.key,
  });
  final Uri uri;
  final Widget child;
  final String mime;
  final List<OverlayWidgets> overlays;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    if (overlays.isEmpty) {
      return child;
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(child: child),
          ...overlays,
        ],
      ),
    );
  }
}
