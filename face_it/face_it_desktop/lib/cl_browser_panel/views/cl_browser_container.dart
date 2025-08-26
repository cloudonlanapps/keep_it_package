import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class CLBrowserContainer extends ConsumerWidget {
  const CLBrowserContainer({super.key, this.child});
  final Widget? child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.only(left: 8.0, bottom: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: ShadTheme.of(context).colorScheme.muted),
        ),
      ),
      child: child ?? Text("Place Holder"),
    );
  }
}
