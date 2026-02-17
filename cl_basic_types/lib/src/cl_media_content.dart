import 'package:meta/meta.dart';

import '../cl_basic_types.dart';

abstract class CLMediaContent {
  const CLMediaContent();

  String get identity;
}

@immutable
class CLMediaText extends CLMediaContent {
  const CLMediaText(this.text);
  final String text;
  CLMediaType get type => CLMediaType.text;

  @override
  String get identity => text;
}

@immutable
class CLMediaURI extends CLMediaContent {
  const CLMediaURI(this.uri);
  final Uri uri;
  CLMediaType get type => CLMediaType.uri;
  @override
  String get identity => uri.toString();
}

@immutable
class CLMediaUnknown extends CLMediaContent {
  const CLMediaUnknown(this.path);
  final String path;
  CLMediaType get type => CLMediaType.unknown;

  @override
  String get identity => path;
}
