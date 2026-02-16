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
        deleted => 'Deleted'
      };
  String get label => identifier;

  String get keepActionLabel => switch (this) {
        camera => 'Save',
        move => 'Move',
        filePick => 'Import',
        stale => 'Keep',
        incoming => 'Save',
        deleted => 'Restore'
      };
  String get deleteActionLabel => switch (this) {
        camera => 'Discard',
        move => 'Discard',
        filePick => 'Discard',
        stale => 'Discard',
        incoming => 'Discard',
        deleted => 'Delete'
      };

  bool get canDelete => switch (this) { move => false, _ => true };
}
