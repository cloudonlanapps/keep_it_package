import 'package:cl_basic_types/cl_basic_types.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import 'package:store/store.dart';
import 'package:store_tasks/store_tasks.dart';

import '../../models/cl_media_candidate.dart';
import '../../providers/incoming_media.dart';
import 'incoming_media_service.dart';

class IncomingMediaMonitor extends ConsumerWidget {
  const IncomingMediaMonitor({
    required this.child,
    super.key,
  });
  final Widget child;

  static void pushMedia(WidgetRef ref, CLMediaFileGroup sharedMedia) {
    ref.read(incomingMediaStreamProvider.notifier).push(sharedMedia);
  }

  static Future<bool> onPickFiles(
    BuildContext context,
    WidgetRef ref, {
    StoreEntity? collection,
  }) async {
    final picker = ImagePicker();
    final pickedFileList = await picker.pickMultipleMedia();

    if (pickedFileList.isNotEmpty) {
      final items = pickedFileList
          .map(
            (xfile) => CLMediaUnknown(xfile.path),
          )
          .toList();
      final sharedMedia = CLMediaFileGroup(
        entries: items,
        collection: collection,
        contentOrigin: ContentOrigin.filePick,
      );

      if (items.isNotEmpty) {
        IncomingMediaMonitor.pushMedia(ref, sharedMedia);
      }

      return items.isNotEmpty;
    } else {
      return false;
      // User canceled the picker
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final incomingMedia = ref.watch(incomingMediaStreamProvider);
    if (incomingMedia.isEmpty) {
      return child;
    }
    return IncomingMediaHandler(
      incomingMedia: incomingMedia[0],
      onDiscard: ({required result}) {
        ref.read(incomingMediaStreamProvider.notifier).pop();
      },
    );
  }
}
