import 'dart:io';
import 'package:face_it_desktop/models/face/detected_face.dart';
import 'package:face_it_desktop/providers/f_face.dart';
import 'package:face_it_desktop/providers/face_box_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:vertical_percent_indicator/vertical_percent_indicator.dart';

class PopOverWhenReferenceFaceIsAvailable extends ConsumerWidget {
  const PopOverWhenReferenceFaceIsAvailable({required this.face, super.key});
  final DetectedFace face;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = ref.watch(faceBoxPreferenceProvider.select((e) => e.color));
    return Card(
      elevation: 8,
      shadowColor: color,
      margin: const EdgeInsets.all(4),
      child: Container(
        width: 152,
        height: 152,
        decoration: BoxDecoration(
          border: Border.all(color: color),
          borderRadius: const BorderRadius.all(Radius.circular(8)),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(8)),
              child: Image.file(
                File(face.descriptor.imageCache),

                fit: BoxFit.contain,
              ),
            ),
            Positioned(
              right: 4,
              bottom: 0,
              child: ShadButton.link(
                onPressed: () {
                  if (face.status == FaceStatus.foundConfirmed) {
                    ref
                        .read(
                          detectedFaceProvider(
                            face.descriptor.identity,
                          ).notifier,
                        )
                        .removeConfirmation();
                  } else if (face.status == FaceStatus.found) {
                    ref
                        .read(
                          detectedFaceProvider(
                            face.descriptor.identity,
                          ).notifier,
                        )
                        .rejectTaggedPerson(face.guesses![0].person);
                  }
                },
                padding: const EdgeInsets.all(2),
                child: Text(
                  'Not ${face.label}?',
                  style: ShadTheme.of(context).textTheme.list,
                ),
              ),
            ),
            if (face.status == FaceStatus.found)
              Positioned(
                left: 4,
                top: 0,
                child: Tooltip(
                  message:
                      '${face.guesses![0].confidencePercentage}% confidence',
                  child: VerticalBarIndicator(
                    height: 20,
                    width: 5,
                    percent: face.guesses![0].confidence,
                    color: [color.withValues(alpha: .5), color],
                    circularRadius: 0,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
