import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import 'get_registerred_urls.dart';
import 'get_store.dart';

class GetDefaultStore extends ConsumerWidget {
  const GetDefaultStore({
    required this.builder,
    required this.errorBuilder,
    required this.loadingBuilder,
    super.key,
  });

  final Widget Function(CLStore) builder;
  final CLErrorView Function(Object, StackTrace) errorBuilder;
  final CLLoadingView Function() loadingBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GetRegisteredServiceLocations(
      errorBuilder: errorBuilder,
      loadingBuilder: loadingBuilder,
      builder: (registeredLocations, _) {
        return GetStore(
          storeURL: registeredLocations.defaultConfig,
          builder: builder,
          errorBuilder: errorBuilder,
          loadingBuilder: loadingBuilder,
        );
      },
    );
  }
}
