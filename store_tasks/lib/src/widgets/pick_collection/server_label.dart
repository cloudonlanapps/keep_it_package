import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:store/store.dart';

class ServerLabel extends ConsumerWidget {
  const ServerLabel({required this.store, super.key});
  final CLStore store;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Color color;

    // Use isLocal to determine color instead of scheme
    if (store.entityStore.isLocal) {
      color = Colors.grey.shade400;
    } else {
      // Remote server
      color = Colors.green; // FIXME: [LATER] When offline support, change to red
    }

    return Text(
      store.label,
      style: ShadTheme.of(context).textTheme.muted.copyWith(color: color),
    );
  }
}
