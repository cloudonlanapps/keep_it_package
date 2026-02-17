import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/cl_media_candidate.dart';
import '../providers/incoming_media_provider.dart';

/// Actions for managing incoming media state.
@immutable
class IncomingMediaActions {
  const IncomingMediaActions({
    required this.push,
    required this.pop,
  });

  /// Push a new media group to the incoming list.
  final void Function(CLMediaFileGroup) push;

  /// Pop the first media group from the list.
  /// Returns true if an item was removed, false if empty.
  final bool Function() pop;
}

/// Builder widget for incoming media state.
///
/// Wraps [incomingMediaStreamProvider] and exposes the list of incoming media
/// along with actions to modify the state.
class GetIncomingMedia extends ConsumerWidget {
  const GetIncomingMedia({
    required this.builder,
    super.key,
  });

  /// Builder callback receiving the list of media groups and actions.
  final Widget Function(
    List<CLMediaFileGroup> media,
    IncomingMediaActions actions,
  )
  builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final incomingMedia = ref.watch(incomingMediaStreamProvider);

    final actions = IncomingMediaActions(
      push: (item) => ref.read(incomingMediaStreamProvider.notifier).push(item),
      pop: () => ref.read(incomingMediaStreamProvider.notifier).pop(),
    );

    return builder(incomingMedia, actions);
  }
}
