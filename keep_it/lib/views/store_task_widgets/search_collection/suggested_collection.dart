import 'package:cl_entity_viewers/cl_entity_viewers.dart';
import 'package:colan_services/colan_services.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:store/store.dart';

class SuggestedCollection extends StatelessWidget {
  const SuggestedCollection({
    required this.item,
    required this.onSelect,
    super.key,
  });

  final StoreEntity item;
  final void Function(StoreEntity) onSelect;

  @override
  Widget build(BuildContext context) {
    final targetStore = item.store;
    return Center(
      child: GestureDetector(
        onTap: () => onSelect(item),
        child: GetEntities(
          store: targetStore,
          parentId: item.id,
          errorBuilder: (_, _) =>
              CLErrorView.custom(child: CLEntityView(entity: item)),
          loadingBuilder: () =>
              CLLoadingView.custom(child: CLEntityView(entity: item)),
          builder: (children) {
            return CLEntityView(entity: item, children: children);
          },
        ),
      ),
    );
  }
}
