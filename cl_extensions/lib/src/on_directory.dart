import 'dart:io';

extension UtilExtensionOnDirectory on Directory {
  void clear() {
    if (existsSync()) {
      final contents = listSync();
      try {
        for (final content in contents) {
          if (content is File) {
            content.deleteSync();
          } else if (content is Directory) {
            content.deleteSync(recursive: true);
          }
        }
      } catch (e) {
        /* ignore if fails */
      }
    }
  }

  int fileCount() {
    var count = 0;
    for (final entry in listSync(recursive: true)) {
      if (entry is File) {
        count++;
      }
    }
    return count;
  }

  bool isEmpty() => listSync().isEmpty;
}
