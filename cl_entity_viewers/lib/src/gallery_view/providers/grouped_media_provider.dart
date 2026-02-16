import 'package:cl_basic_types/viewer_types.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'media_grouper.dart';

final groupedMediaProvider =
    StateProvider.family<List<ViewerEntityGroup<ViewerEntity>>, ViewerEntities>(
        (ref, entities) {
  final groupBy = ref.watch(groupMethodProvider);

  return groupBy.getGrouped(entities);
});
