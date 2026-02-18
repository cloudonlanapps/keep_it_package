import 'package:flutter/material.dart';
import 'package:store/store.dart';

class ServerLabel extends StatelessWidget {
  const ServerLabel({required this.store, super.key});
  final CLStore store;

  @override
  Widget build(BuildContext context) {
    final Color color;

    if (store.entityStore.isLocal) {
      color = Colors.grey.shade400;
    } else {
      // Remote server
      color =
          Colors.green; // FIXME: [LATER] When offline support, change to red
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        store.label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
