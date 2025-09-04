import 'dart:io';

import 'package:colan_widgets/colan_widgets.dart';
import 'package:face_it_desktop/providers/a_files.dart';
import 'package:face_it_desktop/views/browser/image_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../models/session_candidate.dart';
import '../../providers/c_candidates.dart';
import '../../providers/image_provider.dart';
import '../utils/menu_button_active_when_socket_connected.dart';

final ImagePicker _picker = ImagePicker();

class ImageBrowser extends ConsumerWidget {
  const ImageBrowser({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref
        .watch(sessionCandidatesProvider)
        .when(
          data: (sessionCandidates) {
            return Column(
              children: [
                if (sessionCandidates.isEmpty)
                  Expanded(
                    child: Center(
                      child: Text(
                        'Nothing to show',
                        style: ShadTheme.of(context).textTheme.muted,
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: ListView.builder(
                      // The number of items to build in the list
                      itemCount: sessionCandidates.length,
                      shrinkWrap: true,
                      // physics: const NeverScrollableScrollPhysics(),
                      // The builder function that creates each item
                      itemBuilder: (BuildContext context, int index) {
                        return ImageTile(media: sessionCandidates[index]);
                      },
                    ),
                  ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    const MenuButtonActiveWhenSocketConnected(
                      menuItem: CLMenuItem(
                        title: 'Import Folder',
                        icon: Icons.abc,
                      ),
                    ),
                    MenuButtonActiveWhenSocketConnected(
                      menuItem: CLMenuItem(
                        title: 'Import Image',
                        icon: Icons.abc,
                        onTap: () async {
                          ref
                              .read(sessionFilesProvider.notifier)
                              .append(await _picker.pickMultiImage());
                          return true;
                        },
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
          error: (_, _) => Container(),
          loading: Container.new,
        );
  }
}
