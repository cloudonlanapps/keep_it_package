import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import '../providers/target_store_provider.dart';

@immutable
class TargetStoreActions {
  const TargetStoreActions({
    required this.setTargetStore,
  });

  final void Function(CLStore store) setTargetStore;
}

class GetTargetStore extends ConsumerWidget {
  const GetTargetStore({
    required this.builder,
    super.key,
  });

  final Widget Function(CLStore store, TargetStoreActions actions) builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final store = ref.watch(targetStoreProvider);
    final actions = TargetStoreActions(
      setTargetStore: (store) =>
          ref.read(targetStoreProvider.notifier).state = store,
    );

    return builder(store, actions);
  }
}
