import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shimmer/shimmer.dart';

import '../../models/face/bbox.dart';
import '../../providers/b_candidate.dart';
import '../../providers/f_face.dart';
import '../../providers/f_faces.dart';
import '../../providers/face_box_preferences.dart';
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
    final faceIds =
        ref
            .watch(sessionCandidateProvider(widget.image))
            .whenOrNull(data: (data) => data.faceIds) ??
        [];

    final faces = faceIds
        .map(
          (e) => ref
              .watch(detectedFaceProvider(e))
              .whenOrNull(data: (data) => data),
        )
        .toList();
    final candidate = ref
        .watch(sessionCandidateProvider(widget.image))
        .whenOrNull(data: (data) => data);

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
                    if (candidate?.isRecognizing ?? false)
                      Positioned.fill(
                        child: Shimmer.fromColors(
                          baseColor: Colors.grey[300]!.withAlpha(0xF0),
                          highlightColor: Colors.grey[100]!.withAlpha(0xF0),
                          direction: ShimmerDirection.ttb,
                          child: Container(
                            color: Colors.grey[300]!.withAlpha(0xF0),
                          ),
                        ),
                      ),
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

/* 
if (boundingBoxes != null)
                CustomPaint(
                  painter: BboxPainter(
                    bboxes: boundingBoxes,
                    boxColor: const Color.fromARGB(255, 57, 255, 20),
                  ),
                  child:
                      Container(), // A blank container to ensure the painter takes up the full size
                ), */

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

/* class _GradientBackgroundTextPainter extends CustomPainter {
  _GradientBackgroundTextPainter({
    required this.text,
    required this.style,
    required this.gradient,
    required this.padding,
    this.borderRadius,
  });
  final String text;
  final TextStyle style;
  final Gradient gradient;
  final EdgeInsetsGeometry padding;
  final BorderRadiusGeometry? borderRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final textSpan = TextSpan(text: text, style: style);

    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    )..layout();

    final paint = Paint()
      ..shader = gradient.createShader(
        Rect.fromLTWH(0, 0, size.width, size.height),
      );

    final textRect =
        Offset(padding.horizontal / 2, padding.vertical / 2) & textPainter.size;

    if (borderRadius != null) {
      canvas.drawRRect(
        borderRadius!.resolve(TextDirection.ltr).toRRect(textRect),
        paint,
      );
    } else {
      canvas.drawRect(textRect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _GradientBackgroundTextPainter oldDelegate) {
    return oldDelegate.text != text ||
        oldDelegate.style != style ||
        oldDelegate.gradient != gradient ||
        oldDelegate.padding != padding ||
        oldDelegate.borderRadius != borderRadius;
  }
} */
