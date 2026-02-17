import 'dart:developer' as dev;
import 'dart:io' show Platform;

import 'package:camera/camera.dart';
import 'package:cl_camera/cl_camera.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../theme/simple_camera_theme.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  final List<String> _capturedPaths = [];
  late final Future<List<CameraDescription>> _camerasFuture;

  @override
  void initState() {
    super.initState();
    _camerasFuture = _getCameras();
  }

  Future<List<CameraDescription>> _getCameras() async {
    if (!kIsWeb && Platform.isMacOS) return [];
    return availableCameras();
  }

  void _onCapture(String path, {required bool isVideo}) {
    setState(() => _capturedPaths.add(path));
  }

  Future<void> _goToReview() async {
    if (_capturedPaths.isEmpty) return;
    await Navigator.pushNamed(
      context,
      '/captured',
      arguments: List<String>.from(_capturedPaths),
    );
    // Clear the session list after returning from review
    setState(() => _capturedPaths.clear());
  }

  Widget _previewWidget() {
    final count = _capturedPaths.length;
    return GestureDetector(
      onTap: count > 0 ? _goToReview : null,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Icon(
            Icons.photo_library,
            size: 36,
            color: count > 0 ? Colors.white : Colors.white38,
          ),
          if (count > 0)
            Positioned(
              top: -6,
              right: -6,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                child: Text(
                  '$count',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<CameraDescription>>(
      future: _camerasFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            backgroundColor: Colors.black,
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return Scaffold(
          backgroundColor: Colors.black,
          body: CLCamera(
            cameras: snapshot.data!,
            themeData: const SimpleCameraTheme(),
            previewWidget: _previewWidget(),
            onCapture: _onCapture,
            onCancel: () => Navigator.maybePop(context),
            onError: (message, {required error}) {
              dev.log('Camera error: $message', name: 'CLCameraExample', error: error);
              ShadToaster.of(context).show(
                ShadToast.destructive(
                  title: Text(message),
                  description: Text('$error'),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
