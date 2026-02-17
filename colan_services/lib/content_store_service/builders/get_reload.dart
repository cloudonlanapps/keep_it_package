import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/refresh_cache.dart';

class GetReload extends ConsumerWidget {
  const GetReload({
    required this.builder,
    super.key,
  });

  final Widget Function(void Function() reload) builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return builder(
      () => ref.read(reloadProvider.notifier).reload(),
    );
  }
}
