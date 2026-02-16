import 'package:cl_basic_types/viewer_types.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/media_filters.dart' show mediaFiltersProvider;

class GetFilterred extends ConsumerWidget {
  const GetFilterred(
      {super.key,
      required this.candidates,
      required this.builder,
      this.isDisabled = false});
  final bool isDisabled;

  final ViewerEntities candidates;
  final Widget Function(ViewerEntities filterred) builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ViewerEntities filterred;
    if (isDisabled) {
      filterred = candidates;
    } else {
      final mediaFilters = ref.watch(mediaFiltersProvider);
      filterred = ViewerEntities(mediaFilters.apply(candidates.entities));
    }
    return builder(filterred);
  }
}
