import 'package:cl_entity_viewers/cl_entity_viewers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class SelectionControlIcon extends ConsumerWidget {
  const SelectionControlIcon({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GetSelectionMode(
      builder: ({
        required void Function({required bool enable}) onUpdateSelectionmode,
        required selectionMode,
      }) {
        return ShadButton.ghost(
          padding: const EdgeInsets.only(right: 8),
          onPressed: () {
            onUpdateSelectionmode(enable: !selectionMode);
          },
          child: const Icon(LucideIcons.listChecks),
        );
      },
    );
  }
}
