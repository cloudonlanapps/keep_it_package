import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cl_basic_types/viewer_types.dart';
import '../providers/ui_state.dart';

class GetCurrentEntity extends ConsumerWidget {
  const GetCurrentEntity({required this.builder, super.key});
  final Widget Function(ViewerEntity entity) builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entity =
        ref.watch(mediaViewerUIStateProvider.select((e) => e.currentItem));
    return builder(entity);
  }
}
