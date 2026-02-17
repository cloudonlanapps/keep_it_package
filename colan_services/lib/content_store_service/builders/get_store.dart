import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import '../providers/store_provider.dart';

class GetStore extends ConsumerWidget {
  const GetStore({
    required this.storeURL,
    required this.builder,
    required this.errorBuilder,
    required this.loadingBuilder,
    super.key,
  });

  final ServiceLocationConfig storeURL;
  final Widget Function(CLStore) builder;
  final CLErrorView Function(Object, StackTrace) errorBuilder;
  final CLLoadingView Function() loadingBuilder;

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
