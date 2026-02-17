import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'pick_wizard.dart';

class WizardError extends StatelessWidget {
  const WizardError({required this.onClose, super.key, this.error});
  final Object? error;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return _WizardErrorInternal(error: error, onClose: onClose);
  }

  static CLErrorView show(
    BuildContext context, {
    required VoidCallback onClose,
    Object? e,
    StackTrace? st,
  }) {
    return CLErrorView.custom(
      child: PickWizard(
        child: WizardError(
          error: e?.toString(),
          onClose: onClose,
        ),
      ),
    );
  }
}

class _WizardErrorInternal extends StatefulWidget {
  const _WizardErrorInternal({required this.onClose, this.error});
  final Object? error;
  final VoidCallback onClose;

  @override
  State<_WizardErrorInternal> createState() => _WizardErrorInternalState();
}

class _WizardErrorInternalState extends State<_WizardErrorInternal> {
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
                color: ShadTheme.of(context).colorScheme.destructive,
              ),
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
              ),
            ),
          ),
          ShadButton.secondary(
            onPressed: widget.onClose,
            child: Text(
              'Close',
              style: ShadTheme.of(context).textTheme.list.copyWith(
                color: ShadTheme.of(context).colorScheme.destructive,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
