import 'dart:io';
import 'package:flutter/material.dart';

class Media extends StatelessWidget {
  const Media({required this.filePath, super.key, this.width, this.height});

  final String filePath;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return Image.file(File(filePath), width: width, height: height);
  }
}
