import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/face/detected_face.dart';

class FacePreview extends ConsumerWidget {
  const FacePreview({required this.face, super.key});
  final DetectedFace face;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(8)),
      child: Image.file(File(face.descriptor.imageCache)),
    );
  }
}
