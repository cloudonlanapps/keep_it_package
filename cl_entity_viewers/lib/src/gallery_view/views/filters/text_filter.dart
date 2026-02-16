import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shadcn_ui/shadcn_ui.dart';

import 'package:cl_basic_types/cl_basic_types.dart';
import '../../models/filter/base_filter.dart';
import '../../models/filter/string_filter.dart';
import '../../providers/media_filters.dart';

class TextFilterView extends ConsumerStatefulWidget {
  const TextFilterView({required this.filter, super.key});
  final CLFilter<ViewerEntity> filter;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _TextFilterViewState();
}

class _TextFilterViewState extends ConsumerState<TextFilterView> {
  late final TextEditingController controller;

  @override
  void initState() {
    if (widget.filter.filterType != FilterType.stringFilter) {
      throw Exception('filter is not EnumFilter');
    }
    controller = TextEditingController(
      text: (widget.filter as StringFilter<ViewerEntity>).query,
    );
    controller.addListener(updateFilter);
    super.initState();
  }

  void updateFilter() {
    ref
        .read(mediaFiltersProvider.notifier)
        .updateDefautTextSearchFilter(controller.text);
  }

  @override
  void dispose() {
    controller
      ..removeListener(updateFilter)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ShadInput(
      controller: controller,
      placeholder: const Text('Search Media'),
      trailing: controller.text.isNotEmpty
          ? ShadButton(
              width: 16,
              height: 16,
              padding: EdgeInsets.zero,
              decoration: const ShadDecoration(
                secondaryBorder: ShadBorder.none,
                secondaryFocusedBorder: ShadBorder.none,
              ),
              child: Icon(clIcons.textClear, size: 16),
              onPressed: () {
                controller.clear();
              },
            )
          : null,
    );
  }
}
