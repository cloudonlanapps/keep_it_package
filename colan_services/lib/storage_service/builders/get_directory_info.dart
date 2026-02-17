import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/file_system/models/cl_directory.dart';
import '../models/file_system/models/cl_directory_info.dart';
import '../models/file_system/providers/cl_directory_info.dart';

/// Builder for watching directory info streams
class GetDirectoryInfo extends ConsumerWidget {
  const GetDirectoryInfo({
    required this.directories,
    required this.builder,
    required this.errorBuilder,
    required this.loadingBuilder,
    super.key,
  });

  final List<CLDirectory> directories;
  final Widget Function(CLDirectoryInfo?) builder;
  final Widget Function(Object, StackTrace) errorBuilder;
  final Widget Function() loadingBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final infoListAsync = directories
        .map((dir) => ref.watch(dir.infoStream))
        .toList();

    // Check for errors
    for (final asyncValue in infoListAsync) {
      if (asyncValue.hasError) {
        return errorBuilder(asyncValue.error!, asyncValue.stackTrace!);
      }
    }

    // Check if all have data
    if (!infoListAsync.every((async) => async.hasValue)) {
      return loadingBuilder();
    }

    // Combine directory info
    final infoList = infoListAsync
        .map((async) => async.valueOrNull)
        .whereType<CLDirectoryInfo>()
        .toList();

    final combinedInfo = infoList.isEmpty
        ? null
        : infoList.reduce((a, b) => a + b);

    return builder(combinedInfo);
  }
}
