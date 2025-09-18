import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/face/detected_face.dart';
import '../../providers/f_face.dart';
import '../persons/new_person_card.dart';
import '../persons/no_person_card.dart';
import '../persons/person_card.dart';
import 'action_buttons.dart';

class FaceInfoCard extends ConsumerWidget {
  const FaceInfoCard({required this.faceId, super.key, this.hasActions = true});

  final String faceId;
  final bool hasActions;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final face = ref
        .watch(detectedFaceProvider(faceId))
        .whenOrNull(data: (data) => data);

    if (face == null) {
      return const SizedBox.shrink();
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        switch (face.status) {
          FaceStatus.notChecked ||
          FaceStatus.notFound ||
          FaceStatus.notFoundUnknown => NewPersonCard(
            faceId: face.descriptor.identity,
          ),

          FaceStatus.found ||
          FaceStatus.foundConfirmed => PersonCard(face: face),
          FaceStatus.notFoundNotAFace => NoPersonCard(
            faceId: face.descriptor.identity,
          ),
        },
        if (hasActions) ActionButtons(faceId: faceId),
      ],
    );
  }
}
