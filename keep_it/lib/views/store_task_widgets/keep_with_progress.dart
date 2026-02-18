import 'package:cl_basic_types/cl_basic_types.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:store/store.dart';

class KeepWithProgress extends StatelessWidget implements PreferredSizeWidget {
  const KeepWithProgress({
    required this.media2Move,
    required this.newParent,
    required this.onDone,
    super.key,
  });
  final ViewerEntities media2Move;
  final StoreEntity newParent;

  final void Function() onDone;
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Progress>(
      stream: moveMultiple(
        items: media2Move,
        newParent: newParent,
        onDone:
            ({
              required mediaMultiple,
            }) async => onDone(),
      ),
      builder: (context, snapShot) {
        return ProgressBar(
          progress: snapShot.hasData ? snapShot.data?.fractCompleted : null,
        );
      },
    );
  }

  Stream<Progress> moveMultiple({
    required ViewerEntities items,
    required StoreEntity newParent,
    required Future<void> Function({
      required ViewerEntities mediaMultiple,
    })
    onDone,
  }) async* {
    final StoreEntity parentCollection;
    if (newParent.id == null) {
      final saved = await newParent.dbSave();
      if (saved != null) {
        parentCollection = saved;
      } else {
        throw Exception('failed to save parent collection');
      }
    } else {
      parentCollection = newParent;
    }
    if (parentCollection.id == null) {
      throw Exception('failed to save parent collection');
    }

    final updatedItems = <StoreEntity>[];
    for (final (i, item) in items.entities.cast<StoreEntity>().indexed) {
      yield Progress(fractCompleted: i / items.length, currentItem: '');

      updatedItems.add(await parentCollection.accept(item));
    }
    yield const Progress(fractCompleted: 1, currentItem: 'All items are moved');
    await onDone(mediaMultiple: ViewerEntities(updatedItems));
  }

  @override
  Size get preferredSize => const Size.fromHeight(kMinInteractiveDimension * 3);
}
