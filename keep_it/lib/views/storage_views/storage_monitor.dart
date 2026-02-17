import 'package:cl_basic_types/cl_basic_types.dart';
import 'package:colan_services/storage_service/storage_service.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class StorageMonitor extends StatelessWidget {
  const StorageMonitor({super.key});

  @override
  Widget build(BuildContext context) {
    return GetDeviceDirectories(
      loadingBuilder: () => CLLoader.widget(
        debugMessage: 'GetDeviceDirectories',
      ),
      errorBuilder: (object, st) {
        return const SizedBox.shrink();
      },
      builder: (deviceDirectories) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            StorageInfoEntry(
              label: 'Storage Used',
              dirs: deviceDirectories.persistentDirs,
            ),
            StorageInfoEntry(
              label: 'Cache',
              dirs: deviceDirectories.cacheDirs,
              action: ShadButton.secondary(
                onPressed: () async {
                  for (final dir in deviceDirectories.cacheDirs) {
                    dir.path.clear();
                  }
                },
                leading: clIcons.deleteItem.iconFormatted(),
                child: const Text('Clear'),
              ),
            ),
          ],
        );
      },
    );
  }
}
