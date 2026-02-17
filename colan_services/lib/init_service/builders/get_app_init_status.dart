import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/basic_page_service/widgets/cl_error_view.dart';
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
    super.key,
  });

  final AppDescriptor app;
  final Widget Function() builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appInitAsync = ref.watch(appInitProvider(app));
    return appInitAsync.when(
      data: (done) {
        return builder();
      },
      error: (err, _) {
        return Scaffold(
          body: CLErrorView(errorMessage: err.toString()),
        );
      },
      loading: () {
        return Scaffold(
          body: CLLoader.widget(
            debugMessage: 'appInitAsync',
          ),
        );
      },
    );
  }
}
