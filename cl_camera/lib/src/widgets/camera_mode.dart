import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../models/camera_mode.dart';

class MenuCameraMode extends StatelessWidget {
  const MenuCameraMode({
    required this.onUpdateMode,
    required this.currMode,
    super.key,
  });

  final CameraMode currMode;
  final void Function(CameraMode type) onUpdateMode;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: CameraMode.values.map((type) {
            final isSelected = type == currMode;
            return ShadButton.ghost(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              onPressed: () => onUpdateMode(type),
              child: Text(
                type.capitalizedName,
                style: ShadTheme.of(context).textTheme.p.copyWith(
                  color: isSelected
                      ? ShadTheme.of(context).colorScheme.foreground
                      : ShadTheme.of(context).colorScheme.mutedForeground,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
