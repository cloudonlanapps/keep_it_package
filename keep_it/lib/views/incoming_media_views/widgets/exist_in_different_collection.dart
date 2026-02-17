import 'package:cl_basic_types/cl_basic_types.dart';
import 'package:cl_entity_viewers/cl_entity_viewers.dart' show MediaThumbnail;
import 'package:colan_services/colan_services.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:store/store.dart';

class ExistInDifferentCollection extends StatelessWidget {
  const ExistInDifferentCollection({
    required this.onRemove,
    required this.targetMismatch,
    super.key,
  });

  final ViewerEntities targetMismatch;

  final void Function(StoreEntity media) onRemove;

  @override
  Widget build(BuildContext context) {
    final duplicates = targetMismatch;
    if (duplicates.isEmpty) {
      return Center(
        child: Text(
          'Nothing to show here',
          style: ShadTheme.of(context).textTheme.h3,
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Stack(
        children: [
          Positioned(
            bottom: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                'Swipe individual items to leave it in the same group.',
                style: ShadTheme.of(context).textTheme.small.copyWith(
                  color: Theme.of(context).disabledColor,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: ListView.builder(
              itemCount: duplicates.length,
              itemBuilder: (ctx, index) {
                final m = duplicates.entities[index] as StoreEntity;

                return GetEntity(
                  id: m.parentId,
                  errorBuilder: (_, _) {
                    throw UnimplementedError('errorBuilder');
                  },
                  loadingBuilder: () => CLLoader.widget(
                    debugMessage: 'GetAllCollection',
                  ),
                  builder: (currCollection) {
                    /* final currCollection = collections
                        .where((e) => e.id == m.parentId)
                        .firstOrNull; */
                    final String currCollectionLabel;

                    if (m.isDeleted) {
                      currCollectionLabel = 'Deleted Items';
                    } else {
                      currCollectionLabel =
                          currCollection?.label ?? 'somethig wrong';
                    }
                    return SizedBox(
                      height: 80,
                      child: Dismissible(
                        key: Key(m.md5!),
                        direction: DismissDirection.endToStart,
                        onDismissed: (direction) {
                          onRemove(m);
                        },
                        background: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          alignment: AlignmentDirectional.center,
                          child: Text(
                            'Keep the item in "${currCollectionLabel.trim()}"',
                          ),
                        ),
                        child: Row(
                          children: [
                            AspectRatio(
                              aspectRatio: 1,
                              child: Padding(
                                padding: const EdgeInsets.all(2),
                                child: MediaThumbnail(
                                  media: m,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    'Found in '
                                    '"${currCollectionLabel.trim()}"',
                                    textAlign: TextAlign.start,
                                    style: ShadTheme.of(context).textTheme.h4,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
