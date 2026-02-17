import 'package:cl_entity_viewers/cl_entity_viewers.dart';
import 'package:colan_services/colan_services.dart' show GetEntities;
import 'package:colan_widgets/colan_widgets.dart';

import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:store/store.dart' show StoreEntity;

class CollectionPreview extends StatelessWidget {
  const CollectionPreview.preview(
    this.collection, {
    super.key,
  });

  final StoreEntity collection;

  @override
  Widget build(BuildContext context) {
    MediaQuery.of(context);

    return GetFilters(
      builder: (filters) {
        return GetEntities(
          parentId: collection.id,
          errorBuilder: (_, _) => const CLErrorView.image(),
          loadingBuilder: () =>
              const CLLoadingView.custom(child: GreyShimmer()),
          builder: (children) {
            return GetFilterred(
              candidates: children,
              builder: (filterredChildren) {
                return CLEntityView(
                  entity: collection,
                  counter: (filters.isActive || filters.isTextFilterActive)
                      ? Container(
                          margin: const EdgeInsets.all(4),
                          alignment: Alignment.bottomCenter,
                          child: FittedBox(
                            child: ShadBadge(
                              backgroundColor: ShadTheme.of(
                                context,
                              ).colorScheme.mutedForeground,
                              child: Text(
                                '${filterredChildren.entities.where((e) => !e.isCollection).length}/${children.length} matches',
                              ),
                            ),
                          ),
                        )
                      : (collection.childrenCount != null &&
                            collection.childrenCount! > 0)
                      ? Container(
                          margin: const EdgeInsets.all(4),
                          alignment: Alignment.bottomCenter,
                          child: FittedBox(
                            child: ShadBadge(
                              backgroundColor: ShadTheme.of(
                                context,
                              ).colorScheme.primary,
                              child: Text(
                                '${collection.childrenCount} items',
                              ),
                            ),
                          ),
                        )
                      : null,

                  children: children,
                  isFilterredOut: (entity) => !filterredChildren.entities
                      .map((e) => e.id)
                      .contains(entity.id),
                );
              },
            );
          },
        );
      },
    );
  }
}
