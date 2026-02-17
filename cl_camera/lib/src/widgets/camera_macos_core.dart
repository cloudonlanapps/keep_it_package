import 'dart:async';
import 'dart:developer' as dev;
import 'dart:io';

import 'package:camera_macos_plus/camera_macos.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../models/camera_config.dart';
import '../models/camera_mode.dart';
import '../models/cl_camera_theme_data.dart';
import '../state/camera_theme.dart';
import 'camera_mode.dart';
import 'cl_circular_button.dart';

class CLCameraMacOSCore extends StatefulWidget {
  const CLCameraMacOSCore({
    required this.previewWidget,
    required this.onCapture,
    required this.cameraMode,
    required this.onError,
    required this.onCancel,
    required this.config,
    super.key,
  });

  final CameraConfig config;
  final CameraMode cameraMode;
  final void Function(String message, {required dynamic error})? onError;
  final Widget previewWidget;
  final void Function(String, {required bool isVideo}) onCapture;
  final VoidCallback? onCancel;

  @override
  State<CLCameraMacOSCore> createState() => _CLCameraMacOSCoreState();
}

class _CLCameraMacOSCoreState extends State<CLCameraMacOSCore> {
  CameraMacOSController? _controller;

  bool _isRecordingInProgress = false;
  Timer? _timer;
  int _recordingDuration = 0;
  String? _currentVideoPath;

  late CameraMode _cameraMode;
  late CameraConfig _config;

  @override
  void initState() {
    super.initState();
    _cameraMode = widget.cameraMode;
    _config = widget.config;
  }

  @override
  void dispose() {
    _timer?.cancel();
    unawaited(_controller?.destroy());
    super.dispose();
  }

  CameraMacOSMode get _macosMode =>
      _cameraMode.isVideo ? CameraMacOSMode.video : CameraMacOSMode.photo;

  // Key changes when mode or audio toggles → forces CameraMacOSView to rebuild
  // and deliver a fresh controller via onCameraInizialized.
  Key get _cameraViewKey =>
      ValueKey('macos_camera_${_cameraMode.name}_${_config.enableAudio}');

  Future<void> _takePicture() async {
    if (_controller == null) return;
    try {
      final file = await _controller!.takePicture();
      if (file?.bytes == null) {
        const msg = 'No image data returned: CameraMacOSFile.bytes is null';
        dev.log(msg, name: 'CLCameraMacOSCore');
        widget.onError?.call('No image data returned', error: msg);
        return;
      }
      final dir = await getTemporaryDirectory();
      await dir.create(recursive: true);
      final path = '${dir.path}/${DateTime.now().millisecondsSinceEpoch}.tiff';
      dev.log('Writing photo to $path', name: 'CLCameraMacOSCore');
      await File(path).writeAsBytes(file!.bytes!);
      dev.log('Photo captured: $path', name: 'CLCameraMacOSCore');
      if (mounted) {
        widget.onCapture(path, isVideo: false);
      }
    } catch (e, st) {
      dev.log(
        'takePicture failed',
        name: 'CLCameraMacOSCore',
        error: e,
        stackTrace: st,
      );
      widget.onError?.call('Failed to take picture', error: e);
    }
  }

  Future<void> _startVideoRecording() async {
    if (_controller == null) return;
    try {
      final dir = await getTemporaryDirectory();
      await dir.create(recursive: true);
      // Passing url: null allows camera_macos to use its default save location
      // (usually in Library/Cache), avoiding potential path/permission issues.
      dev.log(
        'Starting video recording with default path (url: null)',
        name: 'CLCameraMacOSCore',
      );
      dev.log(
        'Recording config: enableAudio=${_config.enableAudio}',
        name: 'CLCameraMacOSCore',
      );

      await _controller!.recordVideo(
        enableAudio: _config.enableAudio,
      );
      if (mounted) {
        setState(() {
          _isRecordingInProgress = true;
          _recordingDuration = 0;
        });
        _timer = Timer.periodic(const Duration(seconds: 1), (_) {
          if (mounted) {
            setState(() => _recordingDuration++);
          }
        });
      }
    } catch (e, st) {
      dev.log(
        'startVideoRecording failed',
        name: 'CLCameraMacOSCore',
        error: e,
        stackTrace: st,
      );
      if (e is Map) {
        dev.log('Error map details: $e', name: 'CLCameraMacOSCore');
      }
      widget.onError?.call('Failed to start video recording', error: e);
    }
  }

  Future<void> _stopVideoRecording() async {
    if (_controller == null) return;
    try {
      final result = await _controller!.stopRecording();
      dev.log('stopRecording result: $result', name: 'CLCameraMacOSCore');
      String? path;
      if (result?.url != null) {
        dev.log(
          'stopRecording file URL: ${result!.url}',
          name: 'CLCameraMacOSCore',
        );
        try {
          final uri = Uri.parse(result.url!);
          path = uri.isScheme('file') ? uri.toFilePath() : result.url;
          dev.log(
            'Converted result URL to path: $path',
            name: 'CLCameraMacOSCore',
          );
        } catch (e) {
          path = result.url;
        }
      }
      _timer?.cancel();
      path ??= _currentVideoPath;
      if (mounted) {
        setState(() {
          _isRecordingInProgress = false;
          _recordingDuration = 0;
          _currentVideoPath = null;
        });
      }
      if (path != null && mounted) {
        widget.onCapture(path, isVideo: true);
      }
    } catch (e, st) {
      dev.log(
        'stopVideoRecording failed',
        name: 'CLCameraMacOSCore',
        error: e,
        stackTrace: st,
      );
      if (e is Map) {
        dev.log('Error map details (stop): $e', name: 'CLCameraMacOSCore');
      }
      widget.onError?.call('Failed to stop video recording', error: e);
    }
  }

  String _formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:'
          '${minutes.toString().padLeft(2, '0')}:'
          '${secs.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:'
        '${secs.toString().padLeft(2, '0')}';
  }

  Widget _audioMuteButton(CLCameraThemeData themeData) {
    final isEnabled = _config.enableAudio;
    return CircularButton(
      icon: isEnabled
          ? themeData.recordingAudioOn
          : themeData.recordingAudioOff,
      hasDecoration: false,
      foregroundColor: isEnabled
          ? null
          : ShadTheme.of(context).colorScheme.destructive,
      // Same pattern as audioMute() in camera_core: null when recording
      onPressed: _isRecordingInProgress
          ? null
          : () async {
              _config = _config.copyWith(enableAudio: !_config.enableAudio);
              await _config.saveConfig();
              // Key changes → CameraMacOSView rebuilds with new enableAudio
              setState(() {});
            },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeData = CameraTheme.of(context).themeData;
    final mutedColor = ShadTheme.of(context).colorScheme.mutedForeground;

    return SafeArea(
      bottom: false,
      left: false,
      right: false,
      child: Column(
        children: [
          // Top bar
          Row(
            children: [
              if (widget.onCancel != null && Navigator.canPop(context))
                CircularButton(
                  icon: themeData.pagePop,
                  size: 32,
                  hasDecoration: false,
                  onPressed: widget.onCancel,
                ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Flash: not supported on macOS — shown disabled
                    CircularButton(
                      icon: themeData.flashModeOff,
                      hasDecoration: false,
                      foregroundColor: mutedColor,
                    ),
                    // Settings (camera selection, exposure, focus): all
                    // unsupported on macOS — shown disabled
                    CircularButton(
                      icon: themeData.cameraSettings,
                      hasDecoration: false,
                      foregroundColor: mutedColor,
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Camera preview
          Flexible(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black,
                  border: Border.all(
                    color: _isRecordingInProgress
                        ? ShadTheme.of(context).colorScheme.destructive
                        : ShadTheme.of(context).colorScheme.mutedForeground,
                    width: 2,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(1),
                  child: CameraMacOSView(
                    key: _cameraViewKey,
                    cameraMode: _macosMode,
                    enableAudio: _config.enableAudio,
                    onCameraInizialized: (controller) {
                      setState(() => _controller = controller);
                    },
                    onCameraLoading: (_) =>
                        const Center(child: CircularProgressIndicator()),
                  ),
                ),
              ),
            ),
          ),
          // Recording duration display
          if (_isRecordingInProgress)
            Padding(
              padding: const EdgeInsets.only(right: 32),
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  _formatDuration(_recordingDuration),
                  style: ShadTheme.of(context).textTheme.h2,
                ),
              ),
            ),
          // Bottom controls
          LayoutBuilder(
            builder: (context, constraints) {
              return Column(
                children: [
                  // Mode row + audio toggle
                  SizedBox(
                    width: constraints.maxWidth,
                    height:
                        56, // Increased from kMinInteractiveDimension to avoid clipping
                    child: Row(
                      children: [
                        Expanded(
                          child: MenuCameraMode(
                            currMode: _cameraMode,
                            // Guard inside callback — MenuCameraMode.onUpdateMode
                            // is non-nullable, so we ignore during recording
                            onUpdateMode: (mode) {
                              if (!_isRecordingInProgress) {
                                setState(() => _cameraMode = mode);
                              }
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: _audioMuteButton(themeData),
                        ),
                      ],
                    ),
                  ),
                  // Capture row
                  SizedBox(
                    width: constraints.maxWidth,
                    height: kMinInteractiveDimension * 2,
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: 8,
                        right: 8,
                        bottom: 16,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Left: stop button when recording, switch-camera
                          // (disabled) otherwise
                          Expanded(
                            child: _isRecordingInProgress
                                ? CircularButton(
                                    icon: themeData.videoRecordingStop,
                                    onPressed: _stopVideoRecording,
                                  )
                                : CircularButton(
                                    icon: themeData.switchCamera,
                                    hasDecoration: false,
                                    foregroundColor: mutedColor,
                                    // onPressed omitted: null by default (not supported on macOS)
                                  ),
                          ),
                          // Center: main capture button
                          // Disabled (muted) while controller is not yet ready
                          Expanded(
                            child: CircularButton(
                              size: 44,
                              icon: switch ((
                                _cameraMode.isVideo,
                                _isRecordingInProgress,
                              )) {
                                (false, _) => themeData.imageCapture,
                                (true, false) => themeData.videoRecordingStart,
                                // Pause not supported on macOS: show icon disabled
                                (true, true) => themeData.videoRecordingPause,
                              },
                              foregroundColor:
                                  (_controller == null ||
                                      (_cameraMode.isVideo &&
                                          _isRecordingInProgress))
                                  ? mutedColor
                                  : null,
                              onPressed: _controller == null
                                  ? null
                                  : switch ((
                                      _cameraMode.isVideo,
                                      _isRecordingInProgress,
                                    )) {
                                      (false, _) => _takePicture,
                                      (true, false) => _startVideoRecording,
                                      // Pause not supported — button is disabled
                                      (true, true) => null,
                                    },
                            ),
                          ),
                          // Right: preview widget (count badge)
                          Expanded(
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: widget.previewWidget,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
