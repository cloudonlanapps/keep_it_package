import 'package:face_it_desktop/modules/face/views/draw_face.dart';
import 'package:face_it_desktop/modules/face_manager/models/detected_face.dart';
import 'package:flutter/material.dart';

class FaceLayer extends StatelessWidget {
  const FaceLayer({
    required this.showFaceBoxes,
    required this.faces,
    super.key,
  });

  final bool showFaceBoxes;
  final List<DetectedFace?> faces;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (showFaceBoxes)
          for (final face in faces) ...[
            if (face != null) DrawFace.positioned(face: face),
          ],
      ],
    );
  }
}
