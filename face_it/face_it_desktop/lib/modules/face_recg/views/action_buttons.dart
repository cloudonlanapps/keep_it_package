import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../models/detected_face.dart';
import '../providers/f_face.dart';

class ActionButtons extends ConsumerWidget {
  const ActionButtons({required this.faceId, super.key, this.onDone});
  final String faceId;
  final void Function()? onDone;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final face = ref
        .watch(detectedFaceProvider(faceId))
        .whenOrNull(data: (data) => data);

    if (face == null) {
      return const SizedBox.shrink();
    }
    final notAFaceMenuItem = CLMenuItem(
      title: 'not a Face ',
      icon: LucideIcons.x,
      onTap: () async {
        ref
            .read(detectedFaceProvider(face.descriptor.identity).notifier)
            .markNotAFace();
        onDone?.call();
        return true;
      },
    );
    final unknownPersonMenuItem = CLMenuItem(
      title: "I don't know",
      icon: LucideIcons.x,
      onTap: () async {
        ref
            .read(detectedFaceProvider(face.descriptor.identity).notifier)
            .markAsUnknown();
        onDone?.call();
        return true;
      },
    );
    final notThisPersonMenuItem = CLMenuItem(
      title: 'not ${face.label}? ',
      icon: LucideIcons.x,
      onTap: () async {
        if (face.status == FaceStatus.foundConfirmed) {
          ref
              .read(detectedFaceProvider(face.descriptor.identity).notifier)
              .removeConfirmation();
        } else if (face.status == FaceStatus.found) {
          ref
              .read(detectedFaceProvider(face.descriptor.identity).notifier)
              .rejectTaggedPerson(face.guesses![0].person);
        }
        onDone?.call();
        return null;
      },
    );
    final isAFaceMenuItem = CLMenuItem(
      title: 'Mark This As A Face',
      icon: LucideIcons.x,
      onTap: () async {
        ref
            .read(detectedFaceProvider(face.descriptor.identity).notifier)
            .isAFace();
        onDone?.call();
        return null;
      },
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      spacing: 8,
      children: [
        Expanded(
          child: switch (face.status) {
            FaceStatus.notChecked ||
            FaceStatus.notFoundUnknown ||
            FaceStatus.notFound => PopoverButtonBase(
              menuItem: unknownPersonMenuItem,
            ),

            FaceStatus.found ||
            FaceStatus.foundConfirmed => const SizedBox.shrink(),
            FaceStatus.notFoundNotAFace => const SizedBox.shrink(),
          },
        ),

        Expanded(
          child: switch (face.status) {
            FaceStatus.notChecked ||
            FaceStatus.notFoundUnknown ||
            FaceStatus.notFound => PopoverButtonBase(
              menuItem: notAFaceMenuItem,
            ),

            FaceStatus.found || FaceStatus.foundConfirmed => PopoverButtonBase(
              menuItem: notThisPersonMenuItem,
            ),
            FaceStatus.notFoundNotAFace => PopoverButtonBase(
              menuItem: isAFaceMenuItem,
            ),
          },
        ),
      ],
    );
  }
}

class PopoverButtonBase extends ConsumerWidget {
  const PopoverButtonBase({required this.menuItem, super.key});
  final CLMenuItem menuItem;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ShadButton.secondary(
      onPressed: () => menuItem.onTap?.call(),
      child: Text(
        menuItem.title,
        style: ShadTheme.of(context).textTheme.small.copyWith(
          color: ShadTheme.of(context).colorScheme.destructive,
        ),
      ),
    );
  }
}
