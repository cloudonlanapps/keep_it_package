import 'package:cl_basic_types/viewer_types.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/selector.dart';

class SelectorNotifier extends StateNotifier<CLSelector> {
  SelectorNotifier(ViewerEntities entities)
      : super(CLSelector(entities: entities));

  void select(ViewerEntities candidates) {
    state = state.select(candidates);
  }

  void deselect(ViewerEntities candidates) {
    state = state.deselect(candidates);
  }

  void toggle(ViewerEntities candidates) {
    if (state.isSelected(candidates) == SelectionStatus.selectedNone) {
      select(candidates);
    } else {
      deselect(candidates);
    }
  }

  void clear() {
    state = state.clear();
  }

  void updateSelection(ViewerEntities? candidates, {bool? deselect}) {
    if (candidates == null) {
      clear();
    } else if (deselect == null) {
      toggle(candidates);
    } else if (deselect) {
      this.deselect(candidates);
    } else {
      select(candidates);
    }
  }
}

final selectorProvider =
    StateNotifierProvider<SelectorNotifier, CLSelector>((ref) {
  throw Exception('Not in the scope !');
});
