import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

// CLButtonText with icon ! -- Can we reuse?
class LabelViewer extends StatelessWidget {
  const LabelViewer({
    required this.label,
    this.icon,
    this.onTap,
    super.key,
  });

  final void Function()? onTap;
  final IconData? icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            child: Center(
              child: Text(
                label,
                style: ShadTheme.of(context).textTheme.h3,
              ),
            ),
          ),
          if (onTap != null && icon != null) ...[
            const SizedBox(
              width: 8,
            ),
            Transform.translate(
              offset: const Offset(0, -4),
              child: Icon(
                icon,
                size: 16,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
