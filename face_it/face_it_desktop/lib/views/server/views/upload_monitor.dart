import 'package:cl_servers/cl_servers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../providers/server_preference.dart';
import '../providers/uploader.dart';

class UploadMonitor extends ConsumerWidget {
  const UploadMonitor({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final serverPref = ref.watch(serverPreferenceProvider);
    ref.listen(socketConnectionProvider(serverPref), (prev, curr) {
      if (curr.whenOrNull(
            data: (data) => data.socket.connected ? data : null,
          ) !=
          null) {
        ref.read(uploaderProvider.notifier).retry(serverPref);
      }
    });
    return ShadCard(
      height: 180,
      padding: const EdgeInsets.all(8),
      title: Center(
        child: Text(
          'Upload Monitor',
          style: ShadTheme.of(context).textTheme.small,
        ),
      ),
      child: Center(
        child: Text(
          'No image is uploaded for this session',
          style: ShadTheme.of(context).textTheme.muted,
        ),
      ),
    );
  }
}
