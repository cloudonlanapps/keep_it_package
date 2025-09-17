import 'package:face_it_desktop/models/face/detected_face.dart';
import 'package:face_it_desktop/providers/f_face.dart';
import 'package:face_it_desktop/providers/face_box_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class PopOverWhenBboxIsNotAFace extends ConsumerWidget {
  const PopOverWhenBboxIsNotAFace({required this.face, super.key});
  final DetectedFace face;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = ref.watch(faceBoxPreferenceProvider.select((e) => e.color));
    return Card(
      elevation: 8,
      shadowColor: color,
      margin: const EdgeInsets.all(4),
      child: SizedBox(
        height: 30,
        child: ShadButton.link(
          onPressed: () => ref
              .read(detectedFaceProvider(face.descriptor.identity).notifier)
              .isAFace(),
          padding: const EdgeInsets.all(2),
          child: Text(
            'Mark This As A Face',
            style: ShadTheme.of(context).textTheme.muted,
          ),
        ),
      ),
    );
  }
}
