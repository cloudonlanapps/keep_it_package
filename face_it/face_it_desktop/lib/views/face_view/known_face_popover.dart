import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../models/face/detected_face.dart';
import '../../providers/d_online_server.dart';
import '../../providers/d_session_provider.dart';
import '../image/draw_bbox.dart';

class KnownFacePopOver extends StatefulWidget {
  const KnownFacePopOver({required this.face, super.key});
  final DetectedFace face;

  @override
  State<KnownFacePopOver> createState() => _KnownFacePopOverState();
}

class _KnownFacePopOverState extends State<KnownFacePopOver> {
  final popoverController = ShadPopoverController();
  final popoverFlagController = ShadPopoverController();

  @override
  void dispose() {
    popoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ShadPopover(
      decoration: const ShadDecoration(
        color: Colors.transparent,
        border: ShadBorder.none,
      ),
      padding: EdgeInsets.zero,
      controller: popoverController,
      popover: (context) => ShadCard(
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
                FacePreview(face: widget.face),
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
      ),
      child: GestureDetector(
        onTap: popoverController.toggle,
        child: DrawBBox(bbox: widget.face.bbox),
      ),
    );
  }
}

class FacePreview extends ConsumerWidget {
  const FacePreview({required this.face, super.key});
  final DetectedFace face;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    //
    final server = ref
        .read(activeAIServerProvider)
        .whenOrNull(data: (server) => server);
    final session = ref
        .read(sessionProvider)
        .whenOrNull(data: (session) => session);

    final isOnline = server != null && session?.socket.id != null;

    String? url;
    if (isOnline) {
      url =
          '${server.storeURL.uri}/sessions/${session?.socket.id}/face/${face.image}';
    }

    return Container(
      width: 112,
      height: 112,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        border: Border.all(),
        color: Colors.grey.shade400,
      ),
      child: url != null
          ? ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(8)),
              child: Image.network(url),
            )
          : null,
    );
  }
}
