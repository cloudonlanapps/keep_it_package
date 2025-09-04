import 'dart:io';

import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../providers/image_provider.dart';
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
    return ref
        .watch(availableMediaProvider)
        .when(
          data: (data) {
            return Column(
              children: [
                if (data.activeMedia == null)
                  Center(
                    child: Text(
                      'Select a Media',
                      style: ShadTheme.of(context).textTheme.muted,
                    ),
                  )
                else ...[
                  ImageMenu(menuItems: menuItems),
                  Expanded(
                    child: Image.file(File(data.activeMedia!.path), width: 256),
                  ),
                ],
              ],
            );
          },
          error: (_, _) => Container(),
          loading: Container.new,
        );
  }
}
