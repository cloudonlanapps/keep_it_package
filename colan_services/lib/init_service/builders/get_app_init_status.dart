import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/app_descriptor.dart';
import '../providers/app_init_provider.dart';

/// Builder widget that watches app initialization and displays content when ready.
///
/// Waits for the app's async initialization to complete before rendering
/// the builder callback. Shows loading state during initialization and
/// error state if initialization fails.
class GetAppInitStatus extends ConsumerWidget {
  const GetAppInitStatus({
    required this.app,
    required this.builder,
    required this.errorBuilder,
    required this.loadingBuilder,
    super.key,
  });

  final AppDescriptor app;
  final Widget Function() builder;
  final CLErrorView Function(Object, StackTrace) errorBuilder;
  final CLLoadingView Function() loadingBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appInitAsync = ref.watch(appInitProvider(app));
    return appInitAsync.when(
      data: (done) {
        return builder();
      },
      error: (err, st) {
        return CLScaffold(
          body: errorBuilder(err, st),
        );
      },
      loading: () {
        return CLScaffold(
          body: loadingBuilder(),
        );
      },
    );
  }
}
