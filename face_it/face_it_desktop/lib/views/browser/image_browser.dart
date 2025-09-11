import 'package:colan_widgets/colan_widgets.dart';
import 'package:face_it_desktop/providers/a_files.dart';
import 'package:face_it_desktop/views/browser/image_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../providers/b_candidate.dart';
import '../../providers/c_candidates.dart';
import '../../providers/d_online_server.dart';
import '../../providers/d_session_provider.dart';
import '../utils/menu_button_active_when_socket_connected.dart';

final ImagePicker _picker = ImagePicker();

class ImageBrowser extends ConsumerWidget {
  const ImageBrowser({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(sessionCandidatesProvider, (prev, curr) {
      final server = ref
          .read(activeAIServerProvider)
          .whenOrNull(data: (server) => server);
      final session = ref
          .read(sessionProvider)
          .whenOrNull(data: (session) => session);

      final canUpload = server != null && session?.socket.id != null;
      if (canUpload) {
        if (curr.hasValue) {
          for (final candidate in curr.value!) {
            ref
                .read(sessionCandidateProvider(candidate.file).notifier)
                .upload(server, session!.socket.id!);
          }
        }
      }
    });
    final files = ref.watch(sessionFilesProvider.select((e) => e.files));
    return Column(
      children: [
        if (files.isEmpty)
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
              itemCount: files.length,
              shrinkWrap: true,
              // physics: const NeverScrollableScrollPhysics(),
              // The builder function that creates each item
              itemBuilder: (BuildContext context, int index) {
                return ImageTile(file: files[index]);
              },
            ),
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const MenuButtonActiveWhenSocketConnected(
              menuItem: CLMenuItem(title: 'Import Folder', icon: Icons.abc),
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
  }
}
