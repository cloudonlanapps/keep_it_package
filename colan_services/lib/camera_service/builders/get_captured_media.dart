import 'package:cl_basic_types/cl_basic_types.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import '../providers/captured_media_provider.dart';

/// Actions for managing captured media state.
@immutable
class CapturedMediaActions {
  const CapturedMediaActions({
    required this.add,
    required this.clear,
  });

  /// Add a captured media entity to the list.
  final void Function(StoreEntity) add;

  /// Clear all captured media entities.
  final void Function() clear;
}

/// Builder widget for captured media state.
///
/// Wraps [capturedMediaProvider] and exposes captured media entities
/// along with actions to modify the state.
///
/// This is a synchronous StateNotifier (not AsyncValue), so there's no
/// loading or error state to handle.
class GetCapturedMedia extends ConsumerWidget {
  const GetCapturedMedia({
    required this.builder,
    super.key,
  });

  /// Builder callback receiving captured media and actions.
  final Widget Function(ViewerEntities media, CapturedMediaActions actions)
  builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final capturedMedia = ref.watch(capturedMediaProvider);

    final actions = CapturedMediaActions(
      add: (entity) => ref.read(capturedMediaProvider.notifier).add(entity),
      clear: () => ref.read(capturedMediaProvider.notifier).clear(),
    );

    return builder(capturedMedia, actions);
  }
}
