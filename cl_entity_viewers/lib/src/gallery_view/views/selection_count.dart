import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class SelectionCountView extends StatelessWidget {
  const SelectionCountView({
    required this.child,
    super.key,
    this.buttonLabel,
    this.onPressed,
  });
  final Widget child;
  final String? buttonLabel;
  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(child: child),
          if (buttonLabel != null)
            ShadButton.secondary(
              onPressed: onPressed,
              child: Text(
                buttonLabel!,
                style: ShadTheme.of(context).textTheme.small,
              ),
            ),
        ],
      ),
    );
  }
}
