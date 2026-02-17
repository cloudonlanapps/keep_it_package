import 'package:cl_entity_viewers/cl_entity_viewers.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';

import 'package:shadcn_ui/shadcn_ui.dart';

class FilterPopOverMenu extends StatefulWidget {
  const FilterPopOverMenu({super.key});

  @override
  State<FilterPopOverMenu> createState() => _PopoverPageState();
}

class _PopoverPageState extends State<FilterPopOverMenu> {
  final popoverController = ShadPopoverController();

  @override
  void dispose() {
    popoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ShadPopover(
      controller: popoverController,
      popover: (_) => SizedBox(
        width: 288,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ShadButton.ghost(
                  onPressed: popoverController.hide,
                  child: const Icon(LucideIcons.check, size: 25),
                ),
              ],
            ),
            const SingleChildScrollView(
              child: ViewModifierSettings(),
            ),
          ],
        ),
      ),
      child: GetViewModifiers(
        builder: (items) {
          return ShadButton.ghost(
            padding: const EdgeInsets.only(right: 8),
            onPressed: popoverController.toggle,
            child: clIcons.filter.iconFormatted(
              color: items.any((e) => e.isActive)
                  ? ShadTheme.of(context).colorScheme.destructive
                  : null,
            ),
          );
        },
      ),
    );
  }
}
