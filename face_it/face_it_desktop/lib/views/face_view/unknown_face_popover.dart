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
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 8,
        children: [
          FacePreview(face: widget.face),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 8,
              children: [
                const ShadInput(
                  placeholder: Text('Who is this?'),
                  leading: Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(LucideIcons.lock),
                  ),
                ),
                Row(
                  children: [
                    const Expanded(
                      child: ShadButton(
                        leading: Icon(LucideIcons.save300),
                        expands: true,
                        child: Text('Save'),
                      ),
                    ),
                    ShadPopover(
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
                          color: ShadTheme.of(context).colorScheme.destructive,
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
