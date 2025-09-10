import 'package:face_it_desktop/models/bbox.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../providers/b_candidate.dart';

class ImageViewer extends ConsumerStatefulWidget {
  const ImageViewer({required this.image, super.key});
  final XFile image;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ImageViewerState();
}

class _ImageViewerState extends ConsumerState<ImageViewer> {
  bool showFaceBoxes = false;
  @override
  Widget build(BuildContext context) {
    final candidate = ref
        .watch(sessionCandidateProvider(widget.image))
        .whenOrNull(data: (data) => data);

    /* if (candidate == null || candidate.faces == null) {
      return SizedBox(
        width: 500,
        height: 500,
        child: Image.asset(widget.image.path),
      );
    } */

    final boundingBoxes = candidate?.faces?.map((e) {
      return e.bbox;
    }).toList();
    print('boundingBoxes $boundingBoxes');
    final showfaces = boundingBoxes != null && showFaceBoxes;

    return Stack(
      alignment: AlignmentDirectional.bottomEnd,
      children: [
        SizedBox(
          width: 500,
          height: 500,
          child: FittedBox(
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: Image.asset(widget.image.path),
                ),
                if (showfaces)
                  for (final bbox in boundingBoxes) ...[
                    Positioned(
                      left: bbox.xmin,
                      top: bbox.ymin - 100,
                      child: SizedBox(
                        width: bbox.xmax - bbox.xmin,
                        height: 100,
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Text(
                            'Ami',
                            style: ShadTheme.of(context).textTheme.small
                                .copyWith(
                                  color: const Color.fromARGB(255, 57, 255, 20),
                                  fontSize: 100,
                                ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: bbox.xmin,
                      top: bbox.ymin,
                      child: Container(
                        width: bbox.xmax - bbox.xmin,
                        height: bbox.ymax - bbox.ymin,
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 10,
                            color: const Color.fromARGB(255, 57, 255, 20),
                          ),
                        ),
                      ),
                    ),
                  ],
              ],
            ),
          ),
        ),
        Positioned(
          right: 8,
          bottom: 8,
          child: Switch(
            value: showFaceBoxes,
            onChanged: (value) {
              setState(() {
                showFaceBoxes = value;
              });
            },
          ),
        ),
      ],
    );
  }
} /* 
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
