extension UtilExtensionOnMap on Map<String, dynamic> {
  bool get hasID => containsKey('id') && this['id'] != null;

  Map<String, dynamic> removeId() {
    return Map<String, dynamic>.fromEntries(
      entries.where((e) => e.key != 'id'),
    );
  }

  int? get id => containsKey('id') ? this['id'] as int : null;
}
