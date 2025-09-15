import 'dart:math' as math;

import 'package:cl_basic_types/cl_basic_types.dart';
import 'package:face_it_desktop/views/face_view/face_preview.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../models/face/detected_face.dart';

class ConfirmedFace extends StatelessWidget {
  const ConfirmedFace({required this.face, super.key});
  final DetectedFace face;
  @override
  Widget build(BuildContext context) {
    return ShadCard(
      width: 320,
      height: 200,
      padding: const EdgeInsets.all(8),
      child: FittedBox(
        fit: BoxFit.cover,
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 8,
                  children: [
                    Transform(
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.005) // Apply perspective
                        ..rotateX(0.1) // Example: rotate along X-axis
                        ..rotateY(-0.4), // Example: rotate along Y-axis
                      alignment: FractionalOffset.center,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          FacePreview(face: face),
                          Text('', style: ShadTheme.of(context).textTheme.h4),
                        ],
                      ),
                    ),
                    const Icon(LucideIcons.arrowBigRight300),
                    Transform(
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.005) // Apply perspective
                        ..rotateX(0.1) // Example: rotate along X-axis
                        ..rotateY(0.4), // Example: rotate along Y-axis
                      alignment: FractionalOffset.center,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          FacePreview(face: face),
                          Text(
                            face.registeredFace!.personName
                                .capitalizeFirstLetter(),
                            style: ShadTheme.of(context).textTheme.h4,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Align(
              alignment: Alignment.bottomRight,
              child: Icon(LucideIcons.flag300),
            ),
          ],
        ),
      ),
    );
  }
}
