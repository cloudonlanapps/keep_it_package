import 'package:face_it_desktop/modules/face_recg/models/detected_face.dart';
import 'package:face_it_desktop/modules/face_recg/views/draw_face.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../settings/providers/face_box_preferences.dart';
import '../providers/f_face.dart';
import '../providers/f_faces.dart';

class FaceLayer extends ConsumerWidget {
  const FaceLayer({required this.faceIds, super.key});
  final List<String> faceIds;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(detectedFacesProvider);
    final showUnknownFaces = ref.watch(
      faceBoxPreferenceProvider.select((e) => e.showUnknownFaces),
    );

    final faces = faceIds
        .map(
          (e) => ref
              .watch(detectedFaceProvider(e))
              .whenOrNull(data: (data) => data),
        )
        .where((e) => e != null)
        .cast<DetectedFace>()
        .toList();

    final visibleFaces = showUnknownFaces
        ? faces
        : faces.where(
            (e) => ![
              FaceStatus.notFoundUnknown,
              FaceStatus.notFoundNotAFace,
              FaceStatus.notChecked,
              FaceStatus.notFound,
            ].contains(e.status),
          );

    return Stack(
      children: [
        for (final face in visibleFaces) ...[
          DrawFace.positioned(
            face: face,
            key: ValueKey(face.descriptor.identity),
          ),
        ],
      ],
    );
  }
}
