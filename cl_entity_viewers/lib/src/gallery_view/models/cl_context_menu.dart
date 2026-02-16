import 'package:cl_basic_types/viewer_types.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';

import '../views/actions_draggable_menu.dart';

typedef DraggableMenuBuilderType = Widget Function(
  BuildContext, {
  required GlobalKey<State<StatefulWidget>> parentKey,
});

@immutable
abstract class CLContextMenu {
  const CLContextMenu();

  List<CLMenuItem> get actions;

  DraggableMenuBuilderType? draggableMenuBuilder(
    BuildContext context,
    void Function() onDone,
  ) {
    if (actions.isNotEmpty) {
      return (context, {required parentKey}) {
        return ActionsDraggableMenu<ViewerEntity>(
          parentKey: parentKey,
          tagPrefix: 'Selection',
          menuItems: actions.insertOnDone(onDone),
        );
      };
    }

    return null;
  }
}
