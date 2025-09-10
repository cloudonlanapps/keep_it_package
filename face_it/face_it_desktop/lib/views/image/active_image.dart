// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:colan_widgets/colan_widgets.dart';
import 'package:face_it_desktop/views/image/face_preferences_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../providers/b_active_candidate.dart';
import '../../providers/b_candidate.dart';
import '../../providers/face_box_preferences.dart';
import 'image_menu.dart';
import 'image_with_faces.dart';

class ActiveImage extends ConsumerWidget {
  const ActiveImage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeCandidate = ref.watch(activeCandidateProvider);

    final isUploaded = activeCandidate != null && activeCandidate.isUploaded;
    final menuItems = [
      if (isUploaded) ...[
        CLMenuItem(
          title: 'Recognize Faces',
          icon: Icons.abc,

          onTap: isUploaded
              ? () async {
                  await ref
                      .read(
                        sessionCandidateProvider(activeCandidate.file).notifier,
                      )
                      .recognize();

                  return true;
                }
              : null,
        ),
        const CLMenuItem(title: 'Extract Text', icon: Icons.abc),
        const CLMenuItem(title: 'Scan Objects', icon: Icons.abc),
      ],
    ];

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
          ImageMenu(menuItems: menuItems),
          Expanded(child: ImageViewer(image: activeCandidate.file)),
          const ColorSelector(),
        ],
      ],
    );
  }
}

class ColorSelector extends StatelessWidget {
  const ColorSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(8),
      child: Row(spacing: 8, children: [FacePreferencesView()]),
    );
  }
}
