import 'package:face_it_desktop/views/face_view/face_preview.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../models/face/detected_face.dart';

class GuessedFaces extends StatelessWidget {
  const GuessedFaces({required this.face, super.key});
  final DetectedFace face;
  @override
  Widget build(BuildContext context) {
    return ShadCard(
      width: 288,
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 8,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'Identified as ',
                    style: ShadTheme.of(context).textTheme.muted,
                  ),
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '<Person name>',
                        style: ShadTheme.of(context).textTheme.h4,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 8,
            children: [
              FacePreview(face: face),
              const Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 8,
                  children: [
                    ShadButton.outline(
                      leading: Icon(LucideIcons.save300),
                      expands: true,
                      child: Text('Confirm'),
                    ),
                    ShadButton.outline(
                      leading: Icon(LucideIcons.save300),
                      expands: true,
                      child: Text('Reject'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
