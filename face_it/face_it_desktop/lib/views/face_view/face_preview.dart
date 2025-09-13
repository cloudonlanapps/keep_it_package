import 'package:face_it_desktop/models/face/detected_face.dart';
import 'package:face_it_desktop/providers/d_online_server.dart';
import 'package:face_it_desktop/providers/d_session_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FacePreview extends ConsumerWidget {
  const FacePreview({required this.face, super.key});
  final DetectedFace face;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    //
    final server = ref
        .watch(activeAIServerProvider)
        .whenOrNull(data: (server) => server);
    final session = ref
        .watch(sessionProvider)
        .whenOrNull(data: (session) => session);

    final isOnline = server != null && session?.socket.id != null;

    String? url;
    if (isOnline) {
      url =
          '${server.storeURL.uri}/sessions/${session?.socket.id}/face/${face.identity}';
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
          : const Placeholder(),
    );
  }
}
