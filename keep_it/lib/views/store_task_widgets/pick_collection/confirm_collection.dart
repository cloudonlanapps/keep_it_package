import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class ConfirmCollection extends StatelessWidget {
  const ConfirmCollection({
    required this.menuItem,
    super.key,
    this.backgroundColor,
    this.disabledColor,
    this.foregroundColor,
  });
  final CLMenuItem menuItem;
  final Color? backgroundColor;
  final Color? disabledColor;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: 0.2,
      heightFactor: 1,
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor ?? ShadTheme.of(context).colorScheme.primary,
          //border: Border.all(),
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
        ),
        clipBehavior: Clip.antiAlias,
        padding: const EdgeInsets.all(8),
        child: ShadButton.ghost(
          width: double.infinity,
          height: double.infinity,
          padding: const EdgeInsets.all(4),
          foregroundColor: menuItem.onTap == null
              ? disabledColor ?? Colors.grey.shade400
              : foregroundColor ??
                    ShadTheme.of(context).colorScheme.primaryForeground,
          onPressed: menuItem.onTap,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(menuItem.icon, size: 24),
                const SizedBox(height: 4),
                Text(menuItem.title),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
