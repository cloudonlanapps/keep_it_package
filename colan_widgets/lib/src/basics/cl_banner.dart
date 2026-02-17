import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class CLBanner extends StatelessWidget {
  const CLBanner({
    super.key,
    this.backgroundColor,
    this.foregroundColor,
    this.msg = '',
    this.onTap,
  });

  final Color? backgroundColor;
  final Color? foregroundColor;
  final String msg;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    if (msg.isEmpty) {
      return const SizedBox.shrink();
    }
    return GestureDetector(
      onTap: onTap,
      child: Center(
        child: Container(
          color:
              backgroundColor ??
              ShadTheme.of(context).colorScheme.mutedForeground,
          padding: const EdgeInsets.only(
            top: 8,
            bottom: 8,
          ),
          width: double.infinity,

          // height: kMinInteractiveDimension,
          child: Center(
            child: Text(
              msg,
              style: ShadTheme.of(context).textTheme.small.copyWith(
                color:
                    foregroundColor ?? ShadTheme.of(context).colorScheme.muted,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
