import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:face_it_desktop/models/face/detected_face.dart';
import 'package:face_it_desktop/providers/f_face.dart';
import 'package:face_it_desktop/providers/face_box_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:vertical_percent_indicator/vertical_percent_indicator.dart';

class PopOverWhenReferenceFaceIsAvailable extends ConsumerWidget {
  const PopOverWhenReferenceFaceIsAvailable({required this.faceId, super.key});
  final String faceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final face = ref
        .watch(detectedFaceProvider(faceId))
        .whenOrNull(data: (data) => data);

    if (face == null) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      //  radius: BorderRadius.zero,
      width: 350,

      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 2,
        children: [
          PersonCard(face: face),

          Align(
            alignment: Alignment.bottomRight,
            child: ShadButton.secondary(
              onPressed: () {
                if (face.status == FaceStatus.foundConfirmed) {
                  ref
                      .read(
                        detectedFaceProvider(face.descriptor.identity).notifier,
                      )
                      .removeConfirmation();
                } else if (face.status == FaceStatus.found) {
                  ref
                      .read(
                        detectedFaceProvider(face.descriptor.identity).notifier,
                      )
                      .rejectTaggedPerson(face.guesses![0].person);
                }
              },
              child: Text(
                'not ${face.label}? ',
                style: ShadTheme.of(context).textTheme.small.copyWith(
                  color: ShadTheme.of(context).colorScheme.destructive,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PersonCard extends ConsumerWidget {
  const PersonCard({required this.face, super.key});

  final DetectedFace face;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = ref.watch(faceBoxPreferenceProvider.select((e) => e.color));
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                SizedBox(
                  width: 80,
                  child: Center(
                    child: Text(
                      face.label,
                      style: ShadTheme.of(context).textTheme.muted,
                    ),
                  ),
                ),
                const Spacer(),
              ],
            ),
            Row(
              spacing: 8,
              children: [
                DottedBorder(
                  options: RectDottedBorderOptions(color: color),
                  child: Image.file(
                    File(face.descriptor.imageCache),
                    fit: BoxFit.contain,
                    width: 80,
                    height: 80,
                  ),
                ),
                Expanded(
                  child: SizedBox(
                    height: 80,
                    child: Stack(
                      children: [
                        ShadInput(
                          autofocus: true,
                          maxLines: 3,
                          cursorWidth: 1,
                          placeholder: const Text('Write Notes here'),
                          trailing: Align(
                            alignment: Alignment.bottomCenter,
                            child: Icon(
                              LucideIcons.check600,
                              color: ShadTheme.of(context).colorScheme.primary,
                            ),
                          ),
                          style: ShadTheme.of(context).textTheme.muted,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
