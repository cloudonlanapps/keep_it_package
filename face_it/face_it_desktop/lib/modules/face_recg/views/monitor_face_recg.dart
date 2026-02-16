import 'package:cl_server_services/cl_server_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'progress_view_facerecg.dart';

class MonitorFaceRecg extends ConsumerWidget {
  const MonitorFaceRecg({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final serverPref = ref.watch(serverPreferenceProvider);

    return ShadCard(
      height: 180,
      padding: const EdgeInsets.all(8),
      title: Center(
        child: Text(
          'Face Recognition',
          style: ShadTheme.of(context).textTheme.small,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Expanded(child: ProgressViewFaceRecg()),

          Align(
            alignment: Alignment.centerRight,
            child: ShadSwitch(
              value: serverPref.autoFaceRecg,
              label: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Text(
                  'auto-face-rec',
                  style: ShadTheme.of(context).textTheme.muted,
                ),
              ),
              direction: TextDirection.rtl,
              onChanged: (value) {
                ref
                    .read(serverPreferenceProvider.notifier)
                    .toggleAutoFaceRecg();
              },
            ),
          ),
        ],
      ),
    );
  }
}
