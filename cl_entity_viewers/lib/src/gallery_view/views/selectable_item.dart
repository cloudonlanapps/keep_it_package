import 'package:cl_basic_types/viewer_types.dart';
import 'package:colan_widgets/colan_widgets.dart';
import '../../common/views/overlays.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/selector.dart';

import '../providers/select_mode.dart';
import '../providers/selector.dart';

class SelectableItem extends ConsumerWidget {
  const SelectableItem({
    required this.item,
    required this.itemBuilder,
    super.key,
    required this.entities,
  });

  final ViewerEntity item;
  final ViewerEntities entities;
  final Widget Function(BuildContext, ViewerEntity, ViewerEntities) itemBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectionMode = ref.watch(selectModeProvider);

    final itemWidget = itemBuilder(context, item, entities);
    if (!selectionMode) {
      return itemWidget;
    }

    final isSelected =
        ref.watch(
          selectorProvider.select((e) => e.isSelected(ViewerEntities([item]))),
        ) !=
        SelectionStatus.selectedNone;

    final decoration = isSelected
        ? BoxDecoration(
            border: Border.all(
              color: const Color.fromARGB(255, 0x08, 0xFF, 0x08),
            ),
          )
        : BoxDecoration(
            color: Theme.of(context).colorScheme.surface.withAlpha(128),
          );
    return Stack(
      children: [
        Positioned.fill(child: itemWidget),
        Positioned.fill(
          child: GestureDetector(
            onTap: () => ref
                .read(selectorProvider.notifier)
                .updateSelection(ViewerEntities([item])),
            child: SizedBox.expand(
              child: Container(
                decoration: decoration,
                child: isSelected
                    ? Center(child: OverlayIcon(clIcons.itemSelected2))
                    : null,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
