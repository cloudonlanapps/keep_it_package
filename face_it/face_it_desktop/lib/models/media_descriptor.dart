import 'package:flutter/widgets.dart';

@immutable
class MediaDescriptor {
  const MediaDescriptor({required this.path, required this.label});
  final String path;
  final String label;
}
