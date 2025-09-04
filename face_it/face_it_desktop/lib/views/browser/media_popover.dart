import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../providers/a_files.dart';
import '../../providers/b_candidate.dart';
import '../../providers/online_server.dart';
import '../../providers/server_io.dart';

class MediaPopover extends ConsumerStatefulWidget {
  const MediaPopover({required this.file, super.key});
  final XFile file;

  @override
  ConsumerState<MediaPopover> createState() => _MediaPopoverState();
}

class _MediaPopoverState extends ConsumerState<MediaPopover> {
  final popoverController = ShadPopoverController();

  @override
  void dispose() {
    popoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = ShadTheme.of(context).textTheme;
    final server = ref
        .watch(onlineServerProvider)
        .whenOrNull(data: (server) => server);
    final session = ref
        .watch(sessionProvider)
        .whenOrNull(data: (session) => session);

    final canUpload = server != null && session?.socket.id != null;

    final candidate = ref
        .watch(sessionCandidateProvider(widget.file))
        .whenOrNull(data: (data) => data);
    final needUpload = candidate != null && candidate.entity == null;
    return ShadPopover(
      controller: popoverController,
      popover: (context) => SizedBox(
        width: 288,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          spacing: 8,
          children: [
            Row(
              spacing: 8,
              children: [
                if (needUpload)
                  ShadIconButton.outline(
                    enabled: canUpload,
                    onPressed: canUpload
                        ? () {
                            ref
                                .read(
                                  sessionCandidateProvider(
                                    widget.file,
                                  ).notifier,
                                )
                                .upload(server, session!.socket.id!);
                            popoverController.toggle();
                          }
                        : null,
                    icon: const Icon(LucideIcons.upload300),
                  )
                else if (candidate != null)
                  const ShadIconButton.ghost(
                    icon: Icon(LucideIcons.check600, color: Colors.blue),
                  ),
                Expanded(child: Text(widget.file.name, style: textTheme.lead)),
                ShadIconButton.outline(
                  onPressed: () {
                    ref.read(sessionFilesProvider.notifier).remove([
                      widget.file,
                    ]);
                    popoverController.toggle();
                  },
                  icon: Icon(
                    LucideIcons.trash,
                    color: ShadTheme.of(context).colorScheme.destructive,
                  ),
                ),
              ],
            ),
            Image.file(File(widget.file.path), width: 256),
          ],
        ),
      ),
      child: ShadIconButton.outline(
        onPressed: popoverController.toggle,
        icon: const Icon(LucideIcons.ellipsis200),
      ),
    );
  }
}
