import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import '../providers/target_store_provider.dart';

/// Builder that overrides targetStoreProvider with a specific store
class WithTargetStoreOverride extends StatelessWidget {
  const WithTargetStoreOverride({
    required this.store,
    required this.builder,
    super.key,
  });

  final CLStore store;
  final Widget Function() builder;

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [targetStoreProvider.overrideWith((ref) => store)],
      child: builder(),
    );
  }
}
