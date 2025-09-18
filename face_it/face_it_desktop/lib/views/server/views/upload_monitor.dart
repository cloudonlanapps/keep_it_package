import 'package:cl_servers/cl_servers.dart';
import 'package:face_it_desktop/views/server/models/upload_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../content_manager.dart/providers/candidates.dart';
import '../providers/server_preference.dart';
import '../providers/uploader.dart';
import 'upload_progress.dart';

class UploadMonitor extends ConsumerWidget {
  const UploadMonitor({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final serverPref = ref.watch(serverPreferenceProvider);
    ref
      ..listen(socketConnectionProvider(serverPref), (prev, curr) {
        if (curr.whenOrNull(
              data: (data) => data.socket.connected ? data : null,
            ) !=
            null) {
          ref.read(uploaderProvider.notifier).retry(serverPref);
        }
      })
      ..listen(serverPreferenceProvider, (prev, curr) {
        if (prev?.autoUpload != curr.autoUpload && curr.autoUpload == true) {
          final candidates = ref.read(
            candidatesProvider.select((e) => e.items),
          );
          for (final filePath in candidates.map((e) => e.file.path)) {
            ref
                .read(uploaderProvider.notifier)
                .upload(filePath, pref: serverPref);
          }
        }
      })
      ..listen(candidatesProvider, (prev, curr) {
        if (serverPref.autoUpload) {
          for (final filePath in curr.items.map((e) => e.file.path)) {
            ref
                .read(uploaderProvider.notifier)
                .upload(filePath, pref: serverPref);
          }
        }
      });

    final uploader = ref
        .watch(uploaderProvider)
        .whenOrNull(data: (data) => data);

    return ShadCard(
      height: 180,
      padding: const EdgeInsets.all(8),
      title: Center(
        child: Text(
          'Upload Monitor',
          style: ShadTheme.of(context).textTheme.small,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Expanded(child: UploadProgressChart()),

          Align(
            alignment: Alignment.centerRight,
            child: ShadSwitch(
              value: serverPref.autoUpload,
              label: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Text(
                  'auto-upload',
                  style: ShadTheme.of(context).textTheme.muted,
                ),
              ),
              direction: TextDirection.rtl,
              onChanged: (value) {
                ref.read(serverPreferenceProvider.notifier).toggleAutoUpload();
              },
            ),
          ),
        ],
      ),
    );
  }
}

class UploadStatistics extends ConsumerWidget {
  const UploadStatistics({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uploader = ref
        .watch(uploaderProvider)
        .whenOrNull(data: (data) => data);

    if (uploader == null) return const SizedBox.shrink();
    return Text(
      '${uploader.countByStatus(UploadStatus.pending)}/${uploader.count} items are pending',
    );
  }
}
