import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'confirm_collection.dart';

class PickWizard extends StatelessWidget {
  const PickWizard({
    required this.child,
    super.key,
    this.menuItem,
  });

  final CLMenuItem? menuItem;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Select a collection',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 56, // Standard height
            decoration: BoxDecoration(
              border: Border.all(
                color: ShadTheme.of(context).colorScheme.primary,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const SizedBox(width: 12),
                const Icon(Icons.search),
                const SizedBox(width: 12),
                Expanded(child: child),
                if (menuItem != null) ...[
                  const VerticalDivider(width: 1),
                  ConfirmCollection(menuItem: menuItem!),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
