import 'dart:io';

import 'package:face_it_desktop/views/face_view/face_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:vertical_percent_indicator/vertical_percent_indicator.dart';

import '../../models/face/detected_face.dart';
import '../../providers/f_face.dart';
import '../../providers/face_box_preferences.dart';

class FaceConfirmed extends ConsumerStatefulWidget {
  const FaceConfirmed({required this.face, super.key});
  final DetectedFace face;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _FaceConfirmedState();
}

class _FaceConfirmedState extends ConsumerState<FaceConfirmed> {
  late final ShadPopoverController popoverFlagController;

  @override
  void initState() {
    popoverFlagController = ShadPopoverController();
    super.initState();
  }

  @override
  void dispose() {
    popoverFlagController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = ref.watch(faceBoxPreferenceProvider.select((e) => e.color));
    return Card(
      elevation: 8,
      shadowColor: color,
      margin: const EdgeInsets.all(4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
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
                    File(widget.face.descriptor.imageCache),

                    fit: BoxFit.contain,
                  ),
                ),
                Positioned(
                  right: 4,
                  bottom: 0,
                  child: ShadButton.link(
                    onPressed: () => ref
                        .read(
                          detectedFaceProvider(
                            widget.face.descriptor.identity,
                          ).notifier,
                        )
                        .removeConfirmation(),
                    padding: const EdgeInsets.all(2),
                    child: Text('Not ${widget.face.label}?'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
