import 'package:face_it_desktop/modules/media/views/media.dart';
import 'package:face_it_desktop/modules/uploader/providers/uploader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../face_manager/views/face_layer.dart';
import '../../settings/providers/face_box_preferences.dart';
import '../../settings/views/quick_settings.dart';
import '../providers/candidates.dart';

class MediaViewer extends ConsumerStatefulWidget {
  const MediaViewer({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ContentViewerState();
}

class _ContentViewerState extends ConsumerState<MediaViewer> {
  @override
  Widget build(BuildContext context) {
    final activeCandidate = ref.watch(
      mediaListProvider.select((candidates) => candidates.activeCandidate),
    );

    final bool showFaceBoxes;
    final List<String>? faces;
    if (activeCandidate != null) {
      faces = ref.watch(
        uploaderProvider.select((e) => e.files[activeCandidate.path]?.faces),
      );
      showFaceBoxes =
          ref.watch(faceBoxPreferenceProvider.select((e) => e.enabled)) &&
          faces != null;
    } else {
      showFaceBoxes = false;
      faces = null;
    }

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
                              child: Media(filePath: activeCandidate.path),
                            ),
                            if (showFaceBoxes)
                              Positioned.fill(
                                child: FaceLayer(faceIds: faces!),
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
