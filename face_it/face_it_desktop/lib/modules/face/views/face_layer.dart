import 'package:cl_servers/cl_servers.dart';
import 'package:face_it_desktop/modules/face/views/draw_face.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FaceLayer extends ConsumerWidget {
  const FaceLayer({required this.faceIds, super.key});
  final List<String> faceIds;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(detectedFacesProvider);

    final faces = faceIds
        .map(
          (e) => ref
              .watch(detectedFaceProvider(e))
              .whenOrNull(data: (data) => data),
        )
        .toList();

    return Stack(
      children: [
        for (final face in faces) ...[
          if (face != null) DrawFace.positioned(face: face),
        ],
      ],
    );
  }
}
