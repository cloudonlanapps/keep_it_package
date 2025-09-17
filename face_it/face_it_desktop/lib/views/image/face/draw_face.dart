import 'package:face_it_desktop/views/image/face/face_pop_over/bbox_is_not_a_face.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../models/face/detected_face.dart';
import '../../../providers/f_face.dart';
import 'draw_bbox.dart';
import 'face_pop_over/ref_face_is_available.dart';
import 'face_pop_over/ref_face_is_not_available.dart';

class DrawFace extends Positioned {
  DrawFace.positioned({required DetectedFace face, super.key})
    : super(
        child: face.status == FaceStatus.notFoundNotAFace
            ? SizedBox(
                width: face.descriptor.bbox.width,
                height: face.descriptor.bbox.height,

                child: DrawFace0(faceId: face.descriptor.identity),
              )
            : SizedBox(
                width: face.descriptor.bbox.width,
                height: face.descriptor.bbox.height + 100,

                child: DrawFace0(faceId: face.descriptor.identity),
              ),
        left: face.descriptor.bbox.xmin,
        top:
            face.descriptor.bbox.ymin -
            (face.status == FaceStatus.notFoundNotAFace ? 0 : 100),
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
      popover: (context) => switch (face.status) {
        FaceStatus.notChecked => PopOverWhenReferenceFaceisNotAvailable(
          face: face,
        ),
        FaceStatus.found => PopOverWhenReferenceFaceIsAvailable(face: face),
        FaceStatus.foundConfirmed => PopOverWhenReferenceFaceIsAvailable(
          face: face,
        ),
        FaceStatus.notFound => PopOverWhenReferenceFaceisNotAvailable(
          face: face,
        ),
        FaceStatus.notFoundNotAFace => PopOverWhenBboxIsNotAFace(face: face),
        FaceStatus.notFoundUnknown => PopOverWhenReferenceFaceisNotAvailable(
          face: face,
        ),
      },

      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: popoverController.toggle,
        child: DrawBBox(faceId: face.descriptor.identity),
      ),
    );
  }
}
