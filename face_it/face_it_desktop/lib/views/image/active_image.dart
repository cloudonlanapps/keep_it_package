import 'dart:io';

import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../providers/b_active_candidate.dart';
import 'image_menu.dart';

class ActiveImage extends ConsumerWidget {
  const ActiveImage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final menuItems = [
      const CLMenuItem(title: 'Recognize Faces', icon: Icons.abc),
      const CLMenuItem(title: 'Extract Text', icon: Icons.abc),
      const CLMenuItem(title: 'Scan Objects', icon: Icons.abc),
    ];
    final activeCandidate = ref.watch(activeCandidateProvider);

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
          Expanded(child: Image.file(File(activeCandidate.path), width: 256)),
        ],
      ],
    );
  }
}
