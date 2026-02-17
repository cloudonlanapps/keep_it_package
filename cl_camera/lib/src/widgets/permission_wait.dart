import 'package:cl_camera/src/state/camera_theme.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class CameraPermissionWait extends StatelessWidget {
  const CameraPermissionWait({
    required this.message,
    this.onDone,
    super.key,
  });

  final String message;
  final VoidCallback? onDone;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FittedBox(
        fit: BoxFit.cover,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: ShadTheme.of(context).colorScheme.mutedForeground,
              ),
              const SizedBox(
                height: 16,
              ),
              Text(
                message,
                style: ShadTheme.of(context).textTheme.large,
              ),
              if (onDone != null) ...[
                const SizedBox(
                  height: 16,
                ),
                ShadButton(
                  onPressed: onDone,
                  leading: Icon(CameraTheme.of(context).themeData.exitCamera),
                  child: const Text('Go back'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
