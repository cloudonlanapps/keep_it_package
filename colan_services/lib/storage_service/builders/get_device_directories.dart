import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/file_system/models/cl_directories.dart';
import '../providers/directories.dart';

class GetDeviceDirectories extends ConsumerWidget {
  const GetDeviceDirectories({
    required this.builder,
    required this.errorBuilder,
    required this.loadingBuilder,
    super.key,
  });
  final Widget Function(CLDirectories settings) builder;
  final CLErrorView Function(Object object, StackTrace st) errorBuilder;
  final CLLoadingView Function() loadingBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref
        .watch(deviceDirectoriesProvider)
        .when(
          loading: loadingBuilder,
          error: errorBuilder,
          data: (data) {
            try {
              return builder(data);
            } catch (e, st) {
              return errorBuilder(e, st);
            }
          },
        );
  }
}
