import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'pick_wizard.dart';

class WizardError extends StatefulWidget {
  const WizardError({required this.onClose, super.key, this.error});
  final Object? error;
  final VoidCallback onClose;

  @override
  State<WizardError> createState() => _WizardErrorState();

  static Widget show(
    BuildContext context, {
    required VoidCallback onClose,
    Object? e,
    StackTrace? st,
  }) {
    return PickWizard(
      child: WizardError(
        error: e?.toString(),
        onClose: onClose,
      ),
    );
  }
}

class _WizardErrorState extends State<WizardError> {
  late final ShadPopoverController popoverController;

  @override
  void initState() {
    popoverController = ShadPopoverController();

    super.initState();
  }

  @override
  void dispose() {
    popoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 8,
        children: [
          Flexible(
            child: Text(
              'Something went wrong.',
              style: ShadTheme.of(context).textTheme.list.copyWith(
                  color: ShadTheme.of(context).colorScheme.destructive),
            ),
          ),
          ShadPopover(
            controller: popoverController,
            popover: (context) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                spacing: 8,
                children: [
                  Text(
                    widget.error?.toString() ?? 'Unknown error',
                  ),
                ],
              );
            },
            child: ShadButton.ghost(
                onPressed: popoverController.toggle,
                child: const Text(
                  'Details',
                )),
          ),
          ShadButton.secondary(
              onPressed: widget.onClose,
              child: Text(
                'Close',
                style: ShadTheme.of(context).textTheme.list.copyWith(
                    color: ShadTheme.of(context).colorScheme.destructive),
              )),
        ],
      ),
    );
  }
}
