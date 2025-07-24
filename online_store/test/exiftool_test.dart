// ignore_for_file: avoid_print, print required for testing

import 'dart:io';

import 'package:test/test.dart';

import 'implementations/get_create_date.dart' show getCreateDate;

void main() {
  test('exiftool process test', () async {
    final directory =
        Directory('/Users/anandasarangaram/Work/github/generated_media');
    final files = directory.listSync(recursive: true);
    expect(directory.existsSync(), true);
    final dates = <String, DateTime?>{};
    final csvContent = StringBuffer();
    for (final (i, entity) in files.indexed) {
      print('Processing $i');
      if (entity is File) {
        final file = entity.absolute.path;
        final date = await getCreateDate(file);
        dates[entity.path] = date;
        csvContent.writeln('${entity.path},$date ');
      }
    }
    final file = File('CreateDate.csv')
      ..writeAsStringSync(csvContent.toString());

    print('${file.absolute.path} is Ready');
  }, timeout: const Timeout(Duration(hours: 1)));
}
