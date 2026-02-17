import 'package:camera/camera.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/cameras_provider.dart';

class GetCameras extends ConsumerWidget {
  const GetCameras({
    required this.builder,
    required this.errorBuilder,
    required this.loadingBuilder,
    super.key,
  });

  final Widget Function({
    required List<CameraDescription> cameras,
  })
  builder;
  final CLErrorView Function(Object, StackTrace) errorBuilder;
  final CLLoadingView Function() loadingBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final camerasAsync = ref.watch(camerasProvider);

    return camerasAsync.when(
      data: (cameras) {
        return builder(cameras: cameras);
      },
      error: errorBuilder,
      loading: loadingBuilder,
    );
  }
}
