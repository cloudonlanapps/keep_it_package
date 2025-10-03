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
        child: SizedBox(
          width: face.descriptor.bbox.width,
          height: face.descriptor.bbox.height + 100,
          child: DrawFace0(
            face: face,
            /* key: ValueKey(
              face.descriptor.identity.hashCode ^ face.status.hashCode,
            ), */
          ),
        ),
        left: face.descriptor.bbox.xmin,
        top: face.descriptor.bbox.ymin - 100,
      );
}

class DrawFace0 extends ConsumerStatefulWidget {
  const DrawFace0({required this.face, super.key});
  final DetectedFace face;

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
    final face = widget.face;

    final faceId = face.descriptor.identity;

    return ShadPopover(
      decoration: const ShadDecoration(
        color: Colors.transparent,
        border: ShadBorder.none,
      ),
      padding: EdgeInsets.zero,
      controller: popoverController,
      popover: (context) {
        return FacePopOver(faceId: faceId, onDone: popoverController.hide);
      },

      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: popoverController.toggle,
        child: FaceBBox(faceId: faceId),
      ),
    );
  }
}

class FacePopOver extends ConsumerWidget {
  const FacePopOver({required this.faceId, super.key, this.onDone});

  final String faceId;
  final void Function()? onDone;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final face = ref
        .watch(detectedFaceProvider(faceId))
        .whenOrNull(data: (data) => data);

    return SizedBox(
      width: 350,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          switch (face?.status) {
            null => const SizedBox.shrink(),
            FaceStatus.notFoundNotAFace => const SizedBox.shrink(),
            FaceStatus.notChecked ||
            FaceStatus.notFound ||
            FaceStatus.notFoundUnknown => NewPersonCard(
              faceId: face!.descriptor.identity,
            ),

            FaceStatus.found ||
            FaceStatus.foundConfirmed => PersonCard(face: face!),
          },
          ActionButtons(faceId: faceId, onDone: onDone),
        ],
      ),
    );
  }
}
