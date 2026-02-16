import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class CLRefreshButton extends StatelessWidget {
  const CLRefreshButton({
    required this.onRefresh,
    super.key,
  });

  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return ShadButton.ghost(
      onPressed: onRefresh,
      child: const Icon(LucideIcons.refreshCcw),
    );
  }
}

class CLRefreshWrapper extends StatelessWidget {
  const CLRefreshWrapper({
    required this.child,
    required this.onRefresh,
    super.key,
  });
  final Widget child;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: child,
    );
  }
}
