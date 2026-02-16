import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class MediaEditorActionBar extends StatelessWidget {
  const MediaEditorActionBar({
    required this.finalizer,
    super.key,
    this.primaryAction,
    this.secondaryActions,
    this.height = 72.0,
  });

  final Widget finalizer;
  final Widget? primaryAction;
  final List<Widget>? secondaryActions;
  final double height;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return Container(
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.background,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.border,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          // Secondary actions (e.g., Mute, Orientation)
          Expanded(
            child: Row(
              children: secondaryActions ?? [],
            ),
          ),

          // Primary action (e.g., Play, Rotate)
          if (primaryAction != null)
            Expanded(
              child: Center(child: primaryAction),
            )
          else
            const Spacer(),

          // Finalization (Save, Discard)
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [finalizer],
            ),
          ),
        ],
      ),
    );
  }
}
