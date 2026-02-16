import 'package:cl_basic_types/viewer_types.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'package:yet_another_date_picker/yet_another_date_picker.dart';

import '../../models/filter/base_filter.dart';
import '../../models/filter/ddmmyyyy_filter.dart';
import '../../providers/media_filters.dart';

class DDMMYYYYFilterViewRow extends ConsumerWidget {
  const DDMMYYYYFilterViewRow({
    required this.filter,
    super.key,
  });
  final CLFilter<ViewerEntity> filter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final defaultDate = DateTime.now();
    final filter = this.filter as DDMMYYYYFilter<ViewerEntity>;

    return ShadCheckbox(
      value: filter.enabled,
      onChanged: (v) {
        ref
            .read(mediaFiltersProvider.notifier)
            .updateFilter(filter, 'enable', v);
      },
      label: Stack(
        children: [
          DateSelector(
            height: 150,
            years: List.generate(
              DateTime.now().year - 1970 + 1,
              (index) => 1970 + index,
            ),
            date: filter.ddmmyyyy ?? DDMMYYYY.fromDateTime(defaultDate),
            onDateChanged: (ddmmyyyy) async {
              ref
                  .read(mediaFiltersProvider.notifier)
                  .updateFilter(filter, 'ddmmyyyy', ddmmyyyy);
            },
            onReset: () {
              ref.read(mediaFiltersProvider.notifier).updateFilter(
                    filter,
                    'ddmmyyyy',
                    DDMMYYYY.fromDateTime(defaultDate),
                  );
            },
          ),
          if (!filter.enabled)
            Positioned.fill(
              child: Container(
                color: ShadTheme.of(context)
                    .colorScheme
                    .muted
                    .withValues(alpha: 0.7),
              ),
            ),
        ],
      ),
    );
  }
}
