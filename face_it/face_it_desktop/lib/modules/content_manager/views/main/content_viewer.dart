import 'dart:io';

import 'package:face_it_desktop/modules/content_manager/models/candidate.dart';
import 'package:face_it_desktop/modules/face/models/detected_face.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../face/providers/f_face.dart';
import '../../../face/providers/f_faces.dart';
import '../../../face/views/draw_face.dart';
import '../../../settings/providers/face_box_preferences.dart';
import '../../../settings/views/quick_settings.dart';
import '../../providers/candidates.dart';

class ContentViewer extends ConsumerStatefulWidget {
  const ContentViewer({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ContentViewerState();
}

class _ContentViewerState extends ConsumerState<ContentViewer> {
  @override
  Widget build(BuildContext context) {
    final activeCandidate = ref.watch(
      candidatesProvider.select((candidates) => candidates.activeCandidate),
    );
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

    return Column(
      children: [
        if (activeCandidate == null)
          Center(
            child: Text(
              'Select a Media',
              style: ShadTheme.of(context).textTheme.muted,
            ),
          )
        else ...[
          Expanded(
            child: LayoutBuilder(
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
                              child: ImageViewer(
                                filePath: activeCandidate.file.path,
                              ),
                            ),
                            FaceLayer(
                              showFaceBoxes: showFaceBoxes,
                              faces: faces,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const QuickSettings(),
        ],
      ],
    );
  }
}

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

class ImageViewer extends StatelessWidget {
  const ImageViewer({required this.filePath, super.key});

  final String filePath;

  @override
  Widget build(BuildContext context) {
    return Image.file(File(filePath));
  }
}
