import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../state/camera_theme.dart';
import 'cl_circular_button.dart';

class FlashControl extends StatelessWidget {
  const FlashControl({required this.controller, super.key});
  final CameraController controller;

  @override
  Widget build(BuildContext context) {
    final cameraThemeData = CameraTheme.of(context).themeData;
    return CircularButton(
      icon: switch (controller.value.flashMode) {
        FlashMode.off => cameraThemeData.flashModeOff,
        FlashMode.auto => cameraThemeData.flashModeAuto,
        FlashMode.always => cameraThemeData.flashModeAlways,
        FlashMode.torch => cameraThemeData.flashModeTorch,
      },
      size: 32,
      hasDecoration: false,
      foregroundColor: ShadTheme.of(context).colorScheme.foreground,
      onPressed: () async {
        var currentFlashMode = controller.value.flashMode;
        var success = false;
        for (var i = 0; i < FlashMode.values.length; i++) {
          if (!success) {
            try {
              await controller.setFlashMode(
                flashModeNext(currentFlashMode),
              );
              success = true;
              break;
            } catch (e) {
              currentFlashMode = flashModeNext(controller.value.flashMode);
            }
          }
        }
      },
    );
  }

  FlashMode flashModeNext(FlashMode currentFlashMode) {
    return switch (currentFlashMode) {
      FlashMode.off => FlashMode.auto,
      FlashMode.auto => FlashMode.always,
      FlashMode.always => FlashMode.off,
      FlashMode.torch => throw Exception("TorchMode can't be used for Camera"),
    };
  }
}
