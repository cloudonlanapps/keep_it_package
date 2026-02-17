import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../state/camera_theme.dart';
import 'cl_circular_button.dart';

enum CameraSettings { cameraSelection, exposureMode, focusMode }

class CameraSettingsHandler extends StatelessWidget {
  const CameraSettingsHandler({
    required this.currentSelection,
    required this.onSelection,
    super.key,
  });
  final CameraSettings? currentSelection;
  final void Function(CameraSettings cameraSettings) onSelection;

  @override
  Widget build(BuildContext context) {
    final cameraThemeData = CameraTheme.of(context).themeData;
    return PopupMenuButton<CameraSettings>(
      initialValue: currentSelection,
      onSelected: onSelection,
      itemBuilder: (context) {
        return CameraSettings.values
            .map(
              (e) => PopupMenuItem<CameraSettings>(
                value: e,
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: Icon(
                        cameraThemeData.popMenuSelectedItem,
                        color: (e == currentSelection)
                            ? ShadTheme.of(context).colorScheme.foreground
                            : Colors.transparent,
                      ),
                    ),
                    Text(e.name),
                  ],
                ),
              ),
            )
            .toList();
      },
      child: CircularButton(
        icon: cameraThemeData.popMenuAnchor,
        size: 32,
        hasDecoration: false,
        foregroundColor: ShadTheme.of(context).colorScheme.foreground,
      ),
    );
  }
}
