import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'utils/icons.dart';

enum EditorFinalActions {
  save,
  saveAsNew,
  revertToOriginal,
  discard;

  String get label => switch (this) {
    save => 'Save',
    saveAsNew => 'Save Copy',
    revertToOriginal => 'Reset to Original',
    discard => 'Discard',
  };
}

class EditorFinalizer extends StatelessWidget {
  const EditorFinalizer({
    required this.onSave,
    required this.onDiscard,
    required this.canDuplicateMedia,
    required this.hasEditAction,
    this.child,
    super.key,
  });
  final Future<void> Function({required bool overwrite}) onSave;
  final Future<void> Function({required bool done}) onDiscard;
  final Widget? child;
  final bool hasEditAction;
  final bool canDuplicateMedia;
  @override
  Widget build(BuildContext context) {
    if (!hasEditAction) {
      return ShadButton.ghost(
        onPressed: () => unawaited(onDiscard(done: true)),
        size: ShadButtonSize.sm,
        padding: EdgeInsets.zero,
        child:
            child ??
            Icon(
              EditorIcons.closeFullscreen,
              color: ShadTheme.of(context).colorScheme.foreground,
              size: 24,
            ),
      );
    }
    return PopupMenuButton<EditorFinalActions>(
      child:
          child ??
          const Padding(
            padding: EdgeInsets.all(8),
            child: Icon(
              EditorIcons.doneEditMedia,
              color: Colors.red,
              size: 24,
            ),
          ),
      onSelected: (value) async {
        switch (value) {
          case EditorFinalActions.save:
            await onSave(overwrite: true);
          case EditorFinalActions.saveAsNew:
            await onSave(overwrite: false);
          case EditorFinalActions.revertToOriginal:
            await onDiscard(done: false);
          case EditorFinalActions.discard:
            await onDiscard(done: true);
        }
      },
      itemBuilder: (context) {
        final values = <EditorFinalActions>[
          EditorFinalActions.save,
          if (canDuplicateMedia) EditorFinalActions.saveAsNew,
          EditorFinalActions.revertToOriginal,
          EditorFinalActions.discard,
        ];

        return values
            .map(
              (e) => PopupMenuItem<EditorFinalActions>(
                value: e,
                child: Text(e.label),
              ),
            )
            .toList();
      },
    );
  }
}
