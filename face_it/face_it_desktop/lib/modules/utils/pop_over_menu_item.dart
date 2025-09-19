import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class PopOverMenuItem extends ConsumerWidget {
  const PopOverMenuItem(this.menuItem, {super.key});
  final CLMenuItem menuItem;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ShadTheme.of(context);
    return ShadButton.ghost(
      padding: EdgeInsets.zero,
      expands: true,
      leading: Icon(
        menuItem.icon,
        color: menuItem.isDestructive ? theme.colorScheme.destructive : null,
      ),
      onPressed: menuItem.onTap,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          menuItem.title,
          style: theme.textTheme.small.copyWith(
            color: menuItem.isDestructive
                ? theme.colorScheme.destructive
                : null,
          ),
        ),
      ),
    );
  }
}
