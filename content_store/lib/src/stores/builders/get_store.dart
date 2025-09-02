import 'package:content_store/src/stores/providers/store_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

class GetStore extends ConsumerWidget {
  const GetStore({
    required this.storeURL,
    required this.builder,
    required this.errorBuilder,
    required this.loadingBuilder,
    super.key,
  });
  final CLUrl storeURL;
  final Widget Function(CLStore) builder;
  final Widget Function(Object, StackTrace) errorBuilder;
  final Widget Function() loadingBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storeAsync = ref.watch(storeProvider(storeURL));

    return storeAsync.when(
      data: builder,
      error: errorBuilder,
      loading: loadingBuilder,
    );
  }
}
