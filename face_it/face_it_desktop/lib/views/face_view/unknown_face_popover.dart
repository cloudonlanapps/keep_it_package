import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../models/face/detected_face.dart';
import 'face_preview.dart';

class UnknownFace extends ConsumerStatefulWidget {
  const UnknownFace({required this.face, super.key});
  final DetectedFace face;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _UnknownnFaceState();
}

class _UnknownnFaceState extends ConsumerState<UnknownFace> {
  final popoverFlagController = ShadPopoverController();

  @override
  void dispose() {
    popoverFlagController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ShadCard(
      width: 360,
      height: 112 + 20,
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 8,
        children: [
          FacePreview(face: widget.face),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Expanded(
                  child: Center(
                    child: ShadInput(
                      placeholder: Text('Who is this?'),
                      leading: Icon(LucideIcons.userPen300),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  mainAxisSize: MainAxisSize.min,
                  spacing: 8,
                  children: [
                    const Expanded(
                      child: ShadButton.outline(
                        expands: true,
                        child: Text('Save'),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ShadPopover(
                        popover: (context) {
                          return const SizedBox(
                            width: 180,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ShadButton.ghost(
                                  child: Text('Ignore this person'),
                                ),
                                ShadButton.ghost(
                                  child: Text('This is not a face'),
                                ),
                              ],
                            ),
                          );
                        },
                        controller: popoverFlagController,
                        child: ShadButton.ghost(
                          onPressed: popoverFlagController.toggle,
                          child: Icon(
                            LucideIcons.flag300,
                            color: ShadTheme.of(
                              context,
                            ).colorScheme.destructive,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
