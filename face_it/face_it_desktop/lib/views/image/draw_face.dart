import 'package:face_it_desktop/models/face/detected_face.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../providers/f_face.dart';
import '../../providers/face_box_preferences.dart';
import '../face_view/known_face.dart';
import '../face_view/unknown_face.dart';
import '../face_view/when_face_is_known.dart';
import '../face_view/when_face_is_not_known.dart';
import 'draw_bbox.dart';

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
        FaceStatus.notChecked => WhenFaceisNotKnown(face: face),
        FaceStatus.found => WhenFaceisKnown(face: face),
        FaceStatus.foundConfirmed => WhenFaceisKnown(face: face),
        FaceStatus.notFound => WhenFaceisNotKnown(face: face),
        FaceStatus.notFoundNotAFace => NotImplementedPlaceholder(face: face),
        FaceStatus.notFoundUnknown => WhenFaceisNotKnown(face: face),
      },

      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: popoverController.toggle,
        child: DrawBBox(faceId: face.descriptor.identity),
      ),
    );
  }
}

class NotImplementedPlaceholder extends ConsumerWidget {
  const NotImplementedPlaceholder({required this.face, super.key});
  final DetectedFace face;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = ref.watch(faceBoxPreferenceProvider.select((e) => e.color));
    return Card(
      elevation: 8,
      shadowColor: color,
      margin: const EdgeInsets.all(4),
      child: SizedBox(
        height: 30,
        child: ShadButton.link(
          onPressed: () => ref
              .read(detectedFaceProvider(face.descriptor.identity).notifier)
              .isAFace(),
          padding: const EdgeInsets.all(2),
          child: Text(
            'Mark This As A Face',
            style: ShadTheme.of(context).textTheme.muted,
          ),
        ),
      ),
    );
  }
}
