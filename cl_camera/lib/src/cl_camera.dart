import 'dart:async';
import 'dart:io' show Platform;

import 'package:camera/camera.dart';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../cl_camera.dart';
import 'models/camera_config.dart';
import 'state/camera_theme.dart';
import 'widgets/camera_core.dart';
import 'widgets/camera_macos_core.dart';
import 'widgets/permission_denied.dart';
import 'widgets/permission_wait.dart';

class CLCamera extends StatefulWidget {
  const CLCamera({
    required this.previewWidget,
    required this.onCapture,
    required this.themeData,
    this.cameras = const [],
    this.cameraMode = CameraMode.photo,
    this.onError,
    super.key,
    this.onCancel,
  });
  final CLCameraThemeData themeData;
  final List<CameraDescription> cameras;

  final CameraMode cameraMode;

  final void Function(String message, {required dynamic error})? onError;
  final Widget previewWidget;

  final void Function(String, {required bool isVideo}) onCapture;
  final VoidCallback? onCancel;

  @override
  State<CLCamera> createState() => _CLCameraState();

  static Future<Map<Permission, PermissionStatus>> checkPermission() async {
    // macOS handles camera/microphone permissions via entitlements natively.
    if (!kIsWeb && Platform.isMacOS) return {};
    var statuses = <Permission, PermissionStatus>{};
    statuses[Permission.camera] = await Permission.camera.status;
    statuses[Permission.microphone] = await Permission.microphone.status;
    statuses[Permission.location] = await Permission.location.status;
    if (!statuses.values.every((e) => e.isGranted)) {
      statuses = await [
        Permission.camera,
        Permission.microphone,
        Permission.location,
      ].request();
    }
    return statuses;
  }

  static Future<bool> get hasPermission async {
    if (!kIsWeb && Platform.isMacOS) return true;
    final statuses = await checkPermission();
    return statuses.values.every((e) => e.isGranted);
  }

  static Future<bool> invokeWithSufficientPermission(
    BuildContext context,
    Future<void> Function() callback, {
    required CLCameraThemeData themeData,
  }) async {
    if (!kIsWeb && Platform.isMacOS) {
      await callback();
      return true;
    }
    final statuses = await checkPermission();
    final hasPermission = statuses.values.every((e) => e.isGranted);
    if (hasPermission) {
      await callback();
      return true;
    }
    if (context.mounted) {
      await showDialog<void>(
        context: context,
        builder: (context) {
          return AlertDialog(
            alignment: Alignment.center,
            insetPadding: const EdgeInsets.all(10),
            content: CameraTheme(
              themeData: themeData,
              child: CameraPermissionDenied(
                statuses: statuses,
                onDone: () {
                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
                },
                onOpenSettings: () async {
                  await openAppSettings();
                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
                },
              ),
            ),
          );
        },
      );
    }
    return false;
  }
}

class _CLCameraState extends State<CLCamera> {
  Map<Permission, PermissionStatus> statuses = {};
  bool? hasPermission;
  @override
  void initState() {
    super.initState();

    unawaited(_requestCameraPermission());
  }

  Future<void> _requestCameraPermission() async {
    statuses = await CLCamera.checkPermission();
    hasPermission = statuses.values.every((e) => e.isGranted);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // macOS uses camera_macos which manages its own permissions via entitlements.
    if (!kIsWeb && Platform.isMacOS) {
      return CameraTheme(
        themeData: widget.themeData,
        child: FutureBuilder(
          future: CameraConfig.loadConfig(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting ||
                !snapshot.hasData) {
              return CameraPermissionWait(
                message: 'Loading Config',
                onDone: widget.onCancel,
              );
            }
            return CLCameraMacOSCore(
              config: snapshot.data!,
              previewWidget: widget.previewWidget,
              onCapture: widget.onCapture,
              onCancel: widget.onCancel,
              onError: widget.onError,
              cameraMode: widget.cameraMode,
            );
          },
        ),
      );
    }

    return CameraTheme(
      themeData: widget.themeData,
      child: switch (hasPermission) {
        null => CameraPermissionWait(
          message: 'Waiting for Camera Permission',
          onDone: widget.onCancel,
        ),
        false => CameraPermissionDenied(
          statuses: statuses,
          onDone: widget.onCancel,
          onOpenSettings: openAppSettings,
        ),
        true => CameraTheme(
          themeData: widget.themeData,
          child: FutureBuilder(
            future: CameraConfig.loadConfig(),
            builder: (context, snapShot) {
              if (snapShot.connectionState == ConnectionState.waiting ||
                  (!snapShot.hasData)) {
                return CameraPermissionWait(
                  message: 'Loading Config',
                  onDone: widget.onCancel,
                );
              }
              return CLCameraCore(
                config: snapShot.data!,
                cameras: widget.cameras,
                previewWidget: widget.previewWidget,
                onCapture: widget.onCapture,
                onCancel: widget.onCancel,
                onError: widget.onError,
                cameraMode: widget.cameraMode,
              );
            },
          ),
        ),
      },
    );
  }
}
