import 'package:flutter/material.dart';

import '../builders/get_directory_info.dart';
import '../models/file_system/models/cl_directory.dart';

class StorageInfoEntry extends StatelessWidget {
  const StorageInfoEntry({
    required this.label,
    required this.dirs,
    super.key,
    this.action,
  });

  final String label;
  final List<CLDirectory> dirs;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return GetDirectoryInfo(
      directories: dirs,
      loadingBuilder: () => ListTile(
        title: Text(label),
        subtitle: const Text('...'),
      ),
      errorBuilder: (e, st) => ListTile(
        title: Text(label),
        subtitle: const Text('Error'),
      ),
      builder: (info) {
        final statistics = info?.statistics ?? 'Empty';
        final trailing = (info != null && info.statistics != 'Empty')
            ? action
            : null;

        if (dirs.length > 1) {
          return ExpansionTile(
            title: Text(label),
            subtitle: Text(statistics),
            trailing: trailing,
            children: [
              for (final directory in dirs)
                Padding(
                  padding: const EdgeInsets.only(left: 32),
                  child: StorageInfoEntry(
                    label: directory.label,
                    dirs: [directory],
                  ),
                ),
            ],
          );
        }
        return ListTile(
          title: Text(label),
          subtitle: Text(statistics),
          trailing: trailing,
        );
      },
    );
  }
}
