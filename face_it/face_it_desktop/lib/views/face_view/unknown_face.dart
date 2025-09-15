import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../models/face/detected_face.dart';
import '../../providers/d_online_server.dart';
import '../../providers/d_session_provider.dart';
import '../../providers/f_faces.dart';
import 'face_preview.dart';

class UnknownFace extends ConsumerStatefulWidget {
  const UnknownFace({required this.face, super.key});
  final DetectedFace face;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _UnknownnFaceState();
}

class _UnknownnFaceState extends ConsumerState<UnknownFace> {
  late final ShadPopoverController popoverFlagController;
  late final TextEditingController textEditingController;

  @override
  void initState() {
    popoverFlagController = ShadPopoverController();
    textEditingController = TextEditingController();
    textEditingController.addListener(refresh);

    super.initState();
  }

  void refresh() {
    setState(() {});
  }

  @override
  void dispose() {
    popoverFlagController.dispose();
    textEditingController
      ..removeListener(refresh)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final server = ref
        .read(activeAIServerProvider)
        .whenOrNull(data: (server) => server);
    final session = ref
        .read(sessionProvider)
        .whenOrNull(data: (session) => session);
    final socketId = session?.socket.id;
    final canUpload = server != null && socketId != null;
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
                Expanded(
                  child: Center(
                    child: ShadInput(
                      controller: textEditingController,
                      placeholder: const Text('Who is this?'),
                      leading: const Icon(LucideIcons.userPen300),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  mainAxisSize: MainAxisSize.min,
                  spacing: 8,
                  children: [
                    Expanded(
                      child: ShadButton.outline(
                        expands: true,
                        onPressed:
                            canUpload && textEditingController.text.isNotEmpty
                            ? () {
                                ref
                                    .read(detectedFacesProvider.notifier)
                                    .registerFace(
                                      server,
                                      session!,
                                      widget.face.identity,
                                      textEditingController.text,
                                    );
                              }
                            : null,
                        enabled:
                            canUpload && textEditingController.text.isNotEmpty,
                        child: const Text('Save'),
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
