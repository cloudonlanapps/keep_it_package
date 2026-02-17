import 'package:cl_entity_viewers/cl_entity_viewers.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';

import 'package:shadcn_ui/shadcn_ui.dart';

import '../../services/entity_viewer_service/models/entity_actions.dart';

class KeepItContextMenu extends StatelessWidget {
  const KeepItContextMenu({
    required this.child,
    super.key,
    this.onTap,
    this.contextMenu,
  });

  final Widget child;
  final Future<bool?> Function()? onTap;
  final EntityActions? contextMenu;

  @override
  Widget build(BuildContext context) {
    final textStyle = ShadTheme.of(context).textTheme.small;
    if (contextMenu == null) {
      return GestureDetector(
        onTap: onTap,
        child: child,
      );
    }

    return ShadContextMenuRegion(
      constraints: const BoxConstraints(minWidth: 100),
      items: [
        for (final item in contextMenu!.basicActions)
          if (item.onTap != null)
            ShadContextMenuItem(
              leading: SizedBox.square(
                child: Center(child: item.icon.iconFormatted()),
              ),
              enabled: item.onTap != null,
              onPressed: item.onTap,
              textStyle: textStyle.copyWith(
                color: item.isDestructive
                    ? ShadTheme.of(context).colorScheme.destructive
                    : null,
              ),
              child: Text(item.title),
            ),
        const Divider(
          height: 8,
        ),
        const SelectMenuItem(),
        const Divider(
          height: 8,
        ),
        ShadContextMenuItem(
          leading: SizedBox.square(
            child: Center(child: clIcons.recycleBin.iconFormatted()),
          ),
          trailing: const Icon(LucideIcons.chevronRight),
          items: [
            for (final item in contextMenu!.destructiveActions)
              if (item.onTap != null)
                ShadContextMenuItem(
                  leading: SizedBox.square(
                    child: Center(
                      child: item.icon.iconFormatted(
                        color: ShadTheme.of(context).colorScheme.destructive,
                      ),
                    ),
                  ),
                  textStyle: textStyle.copyWith(
                    color: item.isDestructive
                        ? ShadTheme.of(context).colorScheme.destructive
                        : null,
                  ),
                  enabled: item.onTap != null,
                  onPressed: item.onTap,
                  child: Text(item.title),
                ),
          ],
          child: const Text('Remove'),
        ),
      ],
      child: GestureDetector(
        onTap: onTap,
        child: child,
      ),
    );
  }
}

class SelectMenuItem extends StatelessWidget {
  const SelectMenuItem({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GetSelectionMode(
      builder:
          ({
            required void Function({required bool enable})
            onUpdateSelectionmode,
            required selectionMode,
          }) {
            return ShadContextMenuItem(
              leading: SizedBox.square(
                child: Center(
                  child: (selectionMode ? clIcons.selected : clIcons.deselected)
                      .iconFormatted(),
                ),
              ),
              enabled: !selectionMode,
              onPressed: () => onUpdateSelectionmode(enable: true),
              child: const Text('Select'),
            );
          },
    );
  }
}
