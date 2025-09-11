import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../models/face.dart';
import '../../providers/d_online_server.dart';
import '../../providers/d_session_provider.dart';
import '../image/draw_bbox.dart';

class PopoverPage extends StatefulWidget {
  const PopoverPage({required this.face, super.key});
  final Face face;

  @override
  State<PopoverPage> createState() => _PopoverPageState();
}

class _PopoverPageState extends State<PopoverPage> {
  final popoverController = ShadPopoverController();

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
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          spacing: 8,
          children: [
            Row(
              children: [
                FacePreview(face: widget.face),
                Expanded(child: Container()),
              ],
            ),

            const SizedBox(height: 4),
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
  final Face face;

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
      child: url != null ? Image.network(url) : null,
    );
  }
}
