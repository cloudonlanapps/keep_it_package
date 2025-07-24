import 'dart:io';

Future<DateTime?> getCreateDate(String filePath) async {
  final result = await Process.run(
    'exiftool',
    ['-csv', '-CreateDate', '-DateTimeOriginal', filePath],
    runInShell: true, // runInShell is often good for system commands like echo
  );
  try {
    if (result.exitCode == 0) {
      final out = result.stdout.toString();
      final x = out.trim().split('\n');
      if (x.length > 1) {
        final csvString = x[1].split(',');
        if (csvString.length > 1) {
          final dateString = csvString[1];
          var formattedString = dateString.replaceFirst(':', '-');
          formattedString = formattedString.replaceFirst(':', '-');
          final dateTime = DateTime.parse(formattedString);
          return dateTime;
        }
      }
    }
  } catch (e) {
    /* ignore error */
  }
  return null;
}
