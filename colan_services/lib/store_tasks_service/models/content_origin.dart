enum ContentOrigin {
  camera,
  move,
  filePick,
  incoming,
  deleted,
  stale;

  String get identifier => switch (this) {
    camera => 'Captured',
    move => 'Moving...',
    filePick => 'Imported',
    stale => 'Unclassified',
    incoming => 'Incoming',
    deleted => 'Deleted',
  };
  String get label => identifier;

  bool get canDelete => switch (this) {
    move => false,
    _ => true,
  };

  String get step1Title => switch (this) {
    camera => 'Review Captured Items',
    move => 'Move Items',
    filePick => 'Review Valid Files',
    incoming => 'Incoming Share',
    deleted => 'Restore Items?',
    stale => 'Unsaved Items',
  };

  String get step2Title => switch (this) {
    camera => 'Save to...',
    move => 'Move to...',
    filePick => 'Import to...',
    incoming => 'Save to...',
    deleted => 'Restore to...',
    stale => 'Save to...',
  };

  String get positiveAction => switch (this) {
    camera => 'Save',
    move => 'Move',
    filePick => 'Import',
    incoming => 'Save',
    deleted => 'Restore',
    stale => 'Keep',
  };

  String get negativeAction => switch (this) {
    camera => 'Discard',
    move => 'Cancel',
    filePick => 'Discard',
    incoming => 'Discard',
    deleted => 'Delete Forever',
    stale => 'Discard',
  };

  // Deprecated: Use positiveAction or step specific titles
  String get keepActionLabel => positiveAction;

  // Deprecated: Use negativeAction
  String get deleteActionLabel => negativeAction;
}
