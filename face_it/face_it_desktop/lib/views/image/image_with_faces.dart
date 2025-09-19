import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/face/bbox.dart';
import '../../providers/f_face.dart';
import '../../providers/f_faces.dart';
import '../settings/providers/face_box_preferences.dart';
import 'face/draw_face.dart';

class ImageViewer extends ConsumerStatefulWidget {
  const ImageViewer({required this.image, super.key});
  final XFile image;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ImageViewerState();
}

class _ImageViewerState extends ConsumerState<ImageViewer> {
  @override
  Widget build(BuildContext context) {
    ref.watch(detectedFacesProvider);
    final showFaceBoxes = ref.watch(
      faceBoxPreferenceProvider.select((e) => e.enabled),
    );
    final faceIds = <String>[];

    final faces = faceIds
        .map(
          (e) => ref
              .watch(detectedFaceProvider(e))
              .whenOrNull(data: (data) => data),
        )
        .toList();

    return LayoutBuilder(
      builder: (context, constrainedBox) {
        return Stack(
          alignment: AlignmentDirectional.bottomEnd,
          children: [
            SizedBox(
              width: constrainedBox.maxWidth,
              height: constrainedBox.maxHeight,
              child: FittedBox(
                child: Stack(
                  children: [
                    Align(
                      alignment: Alignment.topLeft,
                      child: Image.file(File(widget.image.path)),
                    ),
                    if (showFaceBoxes)
                      for (final face in faces) ...[
                        if (face != null) DrawFace.positioned(face: face),
                      ],
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class BboxPainter extends CustomPainter {
  BboxPainter({
    required this.bboxes,
    this.boxColor = Colors.lightGreen,
    this.strokeWidth = 10.0,
  });
  final List<BBox> bboxes;
  final Color boxColor;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = boxColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    for (final bbox in bboxes) {
      final rect = Rect.fromLTRB(bbox.xmin, bbox.ymin, bbox.xmax, bbox.ymax);
      canvas.drawRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant BboxPainter oldDelegate) {
    return oldDelegate.bboxes != bboxes;
  }
}
