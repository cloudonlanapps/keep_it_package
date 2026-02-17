import 'package:camera/camera.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../views/common_widgets/cl_error_view.dart';
import '../providers/cameras_provider.dart';

class GetCameras extends ConsumerWidget {
  const GetCameras({required this.builder, super.key});
  final Widget Function({
    required List<CameraDescription> cameras,
  })
  builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final camerasAsync = ref.watch(camerasProvider);

    return camerasAsync.when(
      data: (cameras) {
        return builder(cameras: cameras);
      },
      error: (e, st) => CLErrorView(errorMessage: e.toString()),
      loading: () => CLLoader.widget(
        debugMessage: 'camerasAsync',
      ),
    );
  }
}
