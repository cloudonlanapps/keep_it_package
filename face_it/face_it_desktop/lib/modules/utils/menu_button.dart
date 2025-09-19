import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class MenuButton extends ConsumerWidget {
  const MenuButton({required this.menuItem, super.key});

  final CLMenuItem menuItem;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ShadButton.outline(
      onPressed: menuItem.onTap,
      child: Text(
        menuItem.title,
        maxLines: 2,
        textAlign: TextAlign.center,
        softWrap: true,
      ),
    );
  }
}
