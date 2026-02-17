import 'package:cl_basic_types/cl_basic_types.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:store/store.dart';

import '../../incoming_media_service/builders/get_incoming_media.dart';
import '../../incoming_media_service/models/cl_media_candidate.dart';
import '../../store_tasks_service/store_tasks_service.dart';
import 'incoming_media_handler.dart';

class IncomingMediaMonitor extends StatelessWidget {
  const IncomingMediaMonitor({
    required this.child,
    super.key,
  });
  final Widget child;

  static void pushMedia(
    IncomingMediaActions actions,
    CLMediaFileGroup sharedMedia,
  ) {
    actions.push(sharedMedia);
  }

  static Future<bool> onPickFiles(
    BuildContext context,
    IncomingMediaActions actions, {
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
        IncomingMediaMonitor.pushMedia(actions, sharedMedia);
      }

      return items.isNotEmpty;
    } else {
      return false;
      // User canceled the picker
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetIncomingMedia(
      builder: (incomingMedia, actions) {
        if (incomingMedia.isEmpty) {
          return child;
        }
        return IncomingMediaHandler(
          incomingMedia: incomingMedia[0],
          onDiscard: ({required result}) {
            actions.pop();
          },
        );
      },
    );
  }
}
