import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

abstract class CLBanner extends ConsumerWidget {
  const CLBanner({super.key});

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref, {
    Color? backgroundColor,
    Color? foregroundColor,
    String msg = '',
    void Function()? onTap,
  }) {
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

  Widget errorBuilder(Object _, StackTrace _) => const SizedBox.shrink();
  Widget loadingBuilder() => CLLoader.widget(debugMessage: widgetLabel);

  String get widgetLabel;
}
