import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cl_basic_types/viewer_types.dart';
import '../builders/get_filterred.dart';
import '../models/cl_context_menu.dart';

import 'cl_raw_gallery_grid_view.dart';

import '../providers/select_mode.dart';
import '../providers/selector.dart';
import 'filter_banner.dart';
import 'selectable_item.dart';
import 'selectable_label.dart';
import 'selection_banner.dart';

class SelectionContol extends ConsumerWidget {
  const SelectionContol(
      {required this.itemBuilder,
      required this.contextMenuBuilder,
      required this.onSelectionChanged,
      super.key,
      required this.filtersDisabled,
      required this.whenEmpty});

  final bool filtersDisabled;
  final Widget whenEmpty;

  final Widget Function(BuildContext, ViewerEntity, ViewerEntities) itemBuilder;

  final CLContextMenu Function(BuildContext, ViewerEntities)?
      contextMenuBuilder;
  final void Function(ViewerEntities)? onSelectionChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selector = ref.watch(selectorProvider);
    ref.listen(selectorProvider, (prev, curr) {
      onSelectionChanged?.call(ViewerEntities(curr.items.toList()));
    });
    final incoming = selector.entities;

    /* return MediaViewService1.pageView(
          media: filterred.map((e) => e as StoreEntity).toList(),
          parentIdentifier: .toString(),
          initialMediaIndex:
              filterred.indexWhere((e) => e.id == initialMediaIndex),
          errorBuilder: errorBuilder,
          loadingBuilder: () => CLLoadingView.widget(
            debugMessage: 'MediaViewService.pageView',
          ),
        ); */

    return GetFilterred(
        candidates: incoming,
        isDisabled: filtersDisabled,
        builder: (filterred) {
          return CLRawGalleryGridView(
            galleryIdentifier: filterred.hashCode.toString(),
            incoming: filterred,
            bannersBuilder: (context, galleryMap) {
              return [
                FilterBanner(filterred: filterred, incoming: incoming),
                if (incoming.entities.isNotEmpty)
                  SelectionBanner(
                    incoming: incoming,
                    galleryMap: galleryMap,
                  ),
              ];
            },
            labelBuilder: (context, galleryMap, gallery) => SelectableLabel(
              gallery: gallery,
              galleryMap: galleryMap,
            ),
            itemBuilder: (context, item, entities) => SelectableItem(
              item: item,
              itemBuilder: itemBuilder,
              entities: entities,
            ),
            columns: 3,
            draggableMenuBuilder: selector.items.isNotEmpty &&
                    contextMenuBuilder != null
                ? contextMenuBuilder!(
                        context, ViewerEntities(selector.items.toList()))
                    .draggableMenuBuilder(
                        context, ref.read(selectModeProvider.notifier).disable)
                : null,
            whenEmpty: whenEmpty,
          );
        });
  }
}
