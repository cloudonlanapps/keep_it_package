extension UtilExtensionOnDuration on Duration {
  String get timestamp {
    final hh = inHours > 0 ? "${inHours.toString().padLeft(2, '0')}:" : '';
    return '$hh'
        "${inMinutes.toString().padLeft(2, '0')}:"
        "${(inSeconds % 60).toString().padLeft(2, '0')}";
  }
}
