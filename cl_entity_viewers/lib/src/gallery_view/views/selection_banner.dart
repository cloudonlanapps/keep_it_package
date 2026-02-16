import 'package:cl_basic_types/viewer_types.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shadcn_ui/shadcn_ui.dart';

import '../models/selector.dart';

import '../providers/select_mode.dart';
import '../providers/selector.dart';

import 'selection_count.dart';

class SelectionBanner extends ConsumerWidget {
  const SelectionBanner({
    required this.incoming,
    super.key,
    this.galleryMap = const [],
  });
  final ViewerEntities incoming;
  final List<ViewerEntityGroup> galleryMap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectionMode = ref.watch(selectModeProvider);
    if (!selectionMode) {
      return SizedBox.shrink();
    }
    final selector = ref.watch(selectorProvider);
    final allCount = selector.entities.length;
    final selectedInAllCount = selector.count;
    final currentItems = ViewerEntities(galleryMap.getEntities.toList());

    final selectionStatusOnVisible =
        selector.isSelected(currentItems) == SelectionStatus.selectedNone;
    final visibleCount = currentItems.length;
    final selectedInVisible = selector.selectedItems(currentItems);
    final selectedInVisibleCount = selectedInVisible.length;

    return SelectionCountView(
      buttonLabel: selectionStatusOnVisible ? 'Select All' : 'Select None',
      onPressed: () {
        ref.read(selectorProvider.notifier).updateSelection(currentItems);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (selectedInAllCount > 0) ...[
            if (selectedInVisibleCount > 0)
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text:
                          '$selectedInVisibleCount of $visibleCount selected.',
                    ),
                    TextSpan(
                      text: ' Clear ',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                        decoration: TextDecoration.underline,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          ref.read(selectorProvider.notifier).updateSelection(
                              selectedInVisible,
                              deselect: true);
                        },
                    ),
                  ],
                ),
              ),
            if (visibleCount < allCount)
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'Total: $selectedInAllCount of $allCount selected',
                    ),
                    TextSpan(
                      text: ' Clear ',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                        decoration: TextDecoration.underline,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () => ref
                            .read(selectorProvider.notifier)
                            .updateSelection(null),
                    ),
                  ],
                ),
              ),
          ] else
            ShadButton.secondary(
              onPressed: ref.read(selectModeProvider.notifier).disable,
              child: const Text(
                'Done',
              ),
            ),
        ],
      ),
    );
  }
}
