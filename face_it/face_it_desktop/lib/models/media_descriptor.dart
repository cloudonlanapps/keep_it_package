// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:flutter/widgets.dart';

@immutable
class MediaDescriptor {
  const MediaDescriptor({required this.path, required this.label});
  final String path;
  final String label;
}
