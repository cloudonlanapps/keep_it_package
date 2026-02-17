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
      padding: const EdgeInsets.all(2),
      child: InputDecorator(
        decoration: InputDecoration(
          //isDense: true,
          contentPadding: const EdgeInsets.fromLTRB(30, 8, 4, 8),
          labelText: 'Select a collection',
          labelStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: ShadTheme.of(context).colorScheme.primary,
            ),
            //borderSide: const BorderSide(width: 3),
            borderRadius: BorderRadius.circular(16),
            gapPadding: 8,
          ),
          focusColor: ShadTheme.of(context).colorScheme.primary,
          suffixIcon: menuItem == null
              ? null
              : ConfirmCollection(menuItem: menuItem!),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: child,
        ),
      ),
    );
  }
}
