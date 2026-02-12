import 'dart:async';

import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';

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
      return GestureDetector(
        onTap: () {
          unawaited(onDiscard(done: true));
        },
        child:
            child ??
            CLIcon.small(
              clIcons.closeFullscreen,
              color: CLTheme.of(context).colors.iconColor,
            ),
      );
    }
    return PopupMenuButton<EditorFinalActions>(
      child:
          child ??
          CLIcon.small(
            clIcons.doneEditMedia,
            color: Colors.red, //CLTheme.of(context).colors.iconColor,
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
