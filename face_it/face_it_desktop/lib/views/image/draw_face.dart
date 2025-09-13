import 'package:face_it_desktop/models/face/detected_face.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../providers/f_face.dart';
import '../face_view/known_face_popover.dart';
import '../face_view/unknown_face_popover.dart';
import 'draw_bbox.dart';

class DrawFace extends Positioned {
  DrawFace.positioned({required DetectedFace face, super.key})
    : super(
        child: SizedBox(
          width: face.bbox.width,
          height: face.bbox.height + 100,

          child: DrawFace0(faceId: face.identity),
        ),
        left: face.bbox.xmin,
        top: face.bbox.ymin - 100,
      );
}

class DrawFace0 extends ConsumerStatefulWidget {
  const DrawFace0({required this.faceId, super.key});
  final String faceId;

  @override
  ConsumerState<DrawFace0> createState() => _DrawFace0State();
}

class _DrawFace0State extends ConsumerState<DrawFace0> {
  final popoverController = ShadPopoverController();

  @override
  void dispose() {
    popoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final face = ref
        .watch(detectedFaceProvider(widget.faceId))
        .whenOrNull(data: (data) => data);
    if (face == null) {
      return const SizedBox.shrink();
    }
    return ShadPopover(
      decoration: const ShadDecoration(
        color: Colors.transparent,
        border: ShadBorder.none,
      ),
      padding: EdgeInsets.zero,
      controller: popoverController,
      popover: (context) => switch (face) {
        (final DetectedFace face) when face.registeredFace != null =>
          GuessedFaces(face: face),
        (final DetectedFace face) when face.guesses != null => GuessedFaces(
          face: face,
        ),
        _ => UnknownFace(face: face),
      },
      child: GestureDetector(
        onTap: popoverController.toggle,
        child: DrawBBox(bbox: face.bbox),
      ),
    );
  }
}
