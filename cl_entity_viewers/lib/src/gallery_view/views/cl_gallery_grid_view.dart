import 'package:cl_basic_types/viewer_types.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/menu_position.dart';
import '../models/cl_context_menu.dart';

import '../providers/selector.dart';
import 'selection_control.dart';

class CLEntitiesGridView extends StatelessWidget {
  const CLEntitiesGridView(
      {required this.incoming,
      required this.itemBuilder,
      required this.contextMenuBuilder,
      required this.filtersDisabled,
      required this.onSelectionChanged,
      super.key,
      required this.whenEmpty});

  final ViewerEntities incoming;
  final Widget Function(BuildContext, ViewerEntity, ViewerEntities) itemBuilder;
  final CLContextMenu Function(BuildContext, ViewerEntities)?
      contextMenuBuilder;
  final void Function(ViewerEntities)? onSelectionChanged;
  final bool filtersDisabled;
  final Widget whenEmpty;

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      key: ValueKey("CLEntitiesGridView ${incoming.hashCode}"),
      overrides: [
        selectorProvider.overrideWith((ref) => SelectorNotifier(incoming)),
        menuPositionNotifierProvider
            .overrideWith((ref) => MenuPositionNotifier()),
      ],
      child: SelectionContol(
        itemBuilder: itemBuilder,
        contextMenuBuilder: contextMenuBuilder,
        onSelectionChanged: onSelectionChanged,
        filtersDisabled: filtersDisabled,
        whenEmpty: whenEmpty,
      ),
    );
  }
}
