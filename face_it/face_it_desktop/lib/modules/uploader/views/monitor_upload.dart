import 'package:cl_servers/cl_servers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../media/providers/auto_upload_monitor.dart';
import '../../server/providers/auto_retry_upload.dart';
import '../providers/uploader.dart';
import 'progress_view_upload.dart';

class MonitorUpload extends ConsumerWidget {
  const MonitorUpload({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final serverPref = ref.watch(serverPreferenceProvider);
    AutoRetryUpload().watch(ref);
    AutoUploadMonitor().watch(ref);

    ref.watch(uploaderProvider);

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
          const Expanded(child: ProgressViewUpload()),

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
