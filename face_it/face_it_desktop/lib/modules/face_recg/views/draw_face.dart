import 'package:face_it_desktop/modules/face_recg/views/action_buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../models/detected_face.dart';
import '../providers/f_face.dart';
import 'draw_bbox.dart';
import 'new_person_card.dart';
import 'person_card.dart';

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
    if (face == null || face.status == FaceStatus.notFoundNotAFace) {
      return const SizedBox.shrink();
    }

    final faceId = face.descriptor.identity;

    return ShadPopover(
      decoration: const ShadDecoration(
        color: Colors.transparent,
        border: ShadBorder.none,
      ),
      padding: EdgeInsets.zero,
      controller: popoverController,
      popover: (context) {
        return SizedBox(
          width: 350,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              switch (face.status) {
                FaceStatus.notChecked ||
                FaceStatus.notFound ||
                FaceStatus.notFoundUnknown => NewPersonCard(
                  faceId: face.descriptor.identity,
                ),

                FaceStatus.found ||
                FaceStatus.foundConfirmed => PersonCard(face: face),
                FaceStatus.notFoundNotAFace => throw Exception(
                  "Can't handle this state",
                ),
              },
              ActionButtons(faceId: faceId),
            ],
          ),
        );
      },

      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: popoverController.toggle,
        child: DrawBBox(faceId: faceId),
      ),
    );
  }
}
