import 'dart:async';

import 'package:cl_basic_types/cl_basic_types.dart';
import 'package:cl_entity_viewers/cl_entity_viewers.dart' show MediaThumbnail;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../providers/captured_media.dart';

class PreviewCapturedMedia extends ConsumerWidget {
  const PreviewCapturedMedia({
    required this.sendMedia,
    super.key,
  });

  final Future<void> Function(ViewerEntities) sendMedia;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final capturedMedia = ref.watch(capturedMediaProvider);
    return capturedMedia.isEmpty
        ? const SizedBox.shrink()
        : GestureDetector(
            onTap: () {
              final capturedMediaCopy = [...capturedMedia.entities];
              ref.read(capturedMediaProvider.notifier).clear();
              unawaited(sendMedia(ViewerEntities(capturedMediaCopy)));
            },
            child: CapturedMediaDecorator(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: MediaThumbnail(
                      media: capturedMedia.entities.last,
                    ),
                  ),
                  Center(
                    child: ShadBadge.destructive(
                      child: Text(capturedMedia.length.toString()),
                    ),
                  ),
                ],
              ),
            ),
          );
  }
}

class CapturedMediaDecorator extends StatelessWidget {
  const CapturedMediaDecorator({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 60,
      height: 60,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: child,
      ),
    );
  }
}
