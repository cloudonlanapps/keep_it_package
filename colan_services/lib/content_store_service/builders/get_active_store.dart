import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import '../providers/active_store_provider.dart';

class GetActiveStore extends ConsumerWidget {
  const GetActiveStore({
    required this.builder,
    required this.errorBuilder,
    required this.loadingBuilder,
    super.key,
  });

  final Widget Function(CLStore) builder;
  final Widget Function(Object, StackTrace) errorBuilder;
  final Widget Function() loadingBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storeAsync = ref.watch(activeStoreProvider);

    return storeAsync.when(
      data: builder,
      error: errorBuilder,
      loading: loadingBuilder,
    );
  }
}
