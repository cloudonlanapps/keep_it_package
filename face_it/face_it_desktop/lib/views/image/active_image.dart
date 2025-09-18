import 'package:face_it_desktop/views/settings/quick_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../content_manager.dart/providers/candidates.dart';
import 'image_with_faces.dart';

class ActiveImage extends ConsumerWidget {
  const ActiveImage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeCandidate = ref.watch(
      candidatesProvider.select((candidates) => candidates.activeCandidate),
    );

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
          Expanded(child: ImageViewer(image: activeCandidate.file)),
          const QuickSettings(),
        ],
      ],
    );
  }
}
