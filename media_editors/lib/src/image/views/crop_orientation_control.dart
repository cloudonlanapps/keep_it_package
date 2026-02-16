import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';

import '../models/aspect_ratio.dart' as aratio;

class CropOrientation extends StatelessWidget {
  const CropOrientation({
    required this.rotateAngle,
    required this.aspectRatio,
    required this.onToggleCropOrientation,
    super.key,
  });

  final double rotateAngle;
  final aratio.AspectRatio? aspectRatio;
  final void Function() onToggleCropOrientation;

  bool isAspectLandScape() {
    final isRotated = rotateAngle == 90 || rotateAngle == 270;
    final isAspectRatioLandscape = aspectRatio?.isLandscape ?? false;
    final isLandscape = (isRotated
        ? !isAspectRatioLandscape
        : isAspectRatioLandscape);
    return isLandscape;
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape = isAspectLandScape();
    final hasOrientation = aspectRatio?.hasOrientation ?? false;
    return GestureDetector(
      onTap: hasOrientation ? onToggleCropOrientation : null,
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _DeviceInOrientation(
              isLandscape: true,
              isDisabled: !hasOrientation || !isLandscape,
            ),
            const SizedBox(
              width: 8,
            ),
            _DeviceInOrientation(
              isLandscape: false,
              isDisabled: !hasOrientation || isLandscape,
            ),
          ],
        ),
      ),
    );
  }
}

//aspectRatio.hasOrientation
class _DeviceInOrientation extends StatelessWidget {
  const _DeviceInOrientation({
    required this.isLandscape,
    this.isDisabled = false,
  });
  final bool isLandscape;
  final bool isDisabled;

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scaleX: isLandscape ? 16 / 9 : 1,
      scaleY: isLandscape ? 1 : 16 / 9,
      child: Icon(
        clIcons.mediaOrientation,
        color: isDisabled
            ? CLTheme.of(context).colors.disabledIconColor
            : CLTheme.of(context).colors.iconColor,
        size: 16,
      ),
    );
  }
}
