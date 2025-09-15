import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/face/f_face_file_cache.dart';

class FacePreview extends ConsumerWidget {
  const FacePreview({required this.faceFileCache, super.key});
  final FaceFileCache faceFileCache;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      width: 112,
      height: 112,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        border: Border.all(),
        color: Colors.grey.shade400,
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        child: Image.file(File(faceFileCache.image)),
      ),
    );
  }
}
