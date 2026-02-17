import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../models/camera_config.dart';
import '../models/camera_mode.dart';
import '../models/extensions.dart';
import '../state/camera_theme.dart';
import 'camera_mode.dart';
import 'camera_settings.dart';
import 'cl_blink.dart';
import 'cl_circular_button.dart';
import 'flash_control.dart';

class CLCameraCore extends StatefulWidget {
  const CLCameraCore({
    required this.cameras,
    required this.previewWidget,
    required this.onCapture,
    required this.cameraMode,
    required this.onError,
    required this.onCancel,
    required this.config,
    super.key,
  });
  final List<CameraDescription> cameras;
  final CameraConfig config;

  //final List<CameraDescription> cameras;

  final CameraMode cameraMode;

  final void Function(String message, {required dynamic error})? onError;
  final Widget previewWidget;

  final void Function(String, {required bool isVideo}) onCapture;
  final VoidCallback? onCancel;

  @override
  State<CLCameraCore> createState() {
    return CLCameraCoreState();
  }
}

class CLCameraCoreState extends State<CLCameraCore>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  CameraController? controller;

  double minAvailableExposureOffset = 0;
  double maxAvailableExposureOffset = 0;
  double currentExposureOffset = 0;

  double _minAvailableZoom = 1;
  double _maxAvailableZoom = 1;
  double _currentScale = 1;
  double _baseScale = 1;

  late CameraMode cameraMode;
  bool _isRecordingInProgress = false;
  bool isPaused = false;
  Timer? timer;
  int recordingDuration = 0; // in seconds

  CameraDescription? currDescription;
  // Counting pointers (number of user fingers on screen)
  int _pointers = 0;

  CameraSettings? cameraSettings;
  late AnimationController cameraSettingsController;
  late Animation<double> cameraSettingsAnimation;

  late CameraConfig config;

  @override
  void initState() {
    super.initState();
    config = widget.config;
    WidgetsBinding.instance.addObserver(this);
    cameraMode = widget.cameraMode;
    cameraSettingsController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    cameraSettingsAnimation = CurvedAnimation(
      parent: cameraSettingsController,
      curve: Curves.easeInCubic,
    );

    unawaited(swapFrontBack());
  }

  @override
  void dispose() {
    if (controller != null) {
      unawaited(
        controller!.dispose().then((_) {
          controller = null;
        }),
      );
    }
    WidgetsBinding.instance.removeObserver(this);
    cameraSettingsController.dispose();
    timer?.cancel();
    timer = null;
    super.dispose();
  }

  // #docregion AppLifecycle
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive) {
      final cameraController = controller;
      // App state changed before we got the chance to initialize.
      if (cameraController == null || !cameraController.value.isInitialized) {
        return;
      }
      controller = null;
      unawaited(cameraController.dispose());
    } else if (state == AppLifecycleState.resumed) {
      unawaited(swapFrontBack(restore: true));
    }
  }

  void animate(CameraSettings? value) {
    if (value == null) {
      unawaited(cameraSettingsController.reverse());
    } else {
      unawaited(cameraSettingsController.forward());
    }
  }

  void showSettings(CameraSettings value) {
    cameraSettings = (cameraSettings == value) ? null : value;
    animate(cameraSettings);
    setState(() {});
  }

  void closeSettings() {
    if (cameraSettings == null) return;
    cameraSettings = null;
    animate(cameraSettings);
    setState(() {});
  }

  Widget cameraSettingWidget(CameraController? cameraController) {
    if (cameraController == null) {
      return const SizedBox.shrink();
    }
    return SizeTransition(
      sizeFactor: cameraSettingsAnimation,
      child: ClipRect(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [Expanded(child: cameraSettingsMenu(cameraController))],
        ),
      ),
    );
  }

  Widget cameraSettingsMenu(CameraController cameraController) {
    {
      return switch (cameraSettings) {
        CameraSettings.exposureMode => exposureModeSettings(cameraController),
        null => Container(),
        CameraSettings.cameraSelection => cameraSelector(widget.cameras),
        CameraSettings.focusMode => focusModeSettings(cameraController),
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    final cameraThemeData = CameraTheme.of(context).themeData;
    if (controller == null || !controller!.value.isInitialized) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    final quarterTurns = getQuarterTurns(getApplicableOrientation(controller!));
    return SafeArea(
      bottom: false,
      left: false,
      right: false,
      child: Column(
        children: <Widget>[
          Row(
            children: [
              if (widget.onCancel != null && Navigator.canPop(context))
                CircularButton(
                  icon: cameraThemeData.pagePop,
                  size: 32,
                  hasDecoration: false,
                  onPressed: widget.onCancel,
                ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    FlashControl(
                      controller: controller!,
                    ),
                    CameraSettingsHandler(
                      currentSelection: cameraSettings,
                      onSelection: showSettings,
                    ),
                  ],
                ),
              ),
            ],
          ),
          cameraSettingWidget(controller),
          Flexible(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                padding: (cameraSettings == null)
                    ? EdgeInsets.zero
                    : const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black,
                  border: Border.all(
                    color:
                        controller != null && controller!.value.isRecordingVideo
                        ? ShadTheme.of(context).colorScheme.destructive
                        : ShadTheme.of(context).colorScheme.mutedForeground,
                    width: 2,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(1),
                  child: _cameraPreviewWidget(),
                ),
              ),
            ),
          ),
          if (cameraSettings == null)
            LayoutBuilder(
              builder: (context, constraints) {
                return Column(
                  children: [
                    if (isPaused && _isRecordingInProgress)
                      CLBlink(
                        blinkDuration: const Duration(milliseconds: 300),
                        child: Padding(
                          padding: const EdgeInsets.only(right: 32),
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              formatDuration(recordingDuration),
                              style: ShadTheme.of(context).textTheme.h2,
                            ),
                          ),
                        ),
                      )
                    else if (_isRecordingInProgress)
                      Padding(
                        padding: const EdgeInsets.only(right: 32),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            formatDuration(recordingDuration),
                            style: ShadTheme.of(context).textTheme.h2,
                          ),
                        ),
                      ),
                    SizedBox(
                      width: constraints.maxWidth,
                      height: kMinInteractiveDimension,
                      child: Row(
                        children: [
                          Expanded(
                            child: MenuCameraMode(
                              currMode: cameraMode,
                              onUpdateMode: (mode) {
                                setState(() {
                                  cameraMode = mode;
                                });
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: audioMute(),
                          ),
                        ],
                      ),
                    ),
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
                            Expanded(
                              child: _isRecordingInProgress
                                  ? CircularButton(
                                      quarterTurns: quarterTurns,
                                      icon: cameraThemeData.videoRecordingStop,
                                      onPressed: stopVideoRecording,
                                    )
                                  : CircularButton(
                                      quarterTurns: quarterTurns,
                                      onPressed: swapFrontBack,
                                      icon: cameraThemeData.switchCamera,
                                      //foregroundColor: Colors.white,
                                      hasDecoration: false,
                                    ),
                            ),
                            Expanded(
                              child: CircularButton(
                                quarterTurns: quarterTurns,
                                size: 44,
                                icon: switch ((
                                  cameraMode.isVideo,
                                  controller!.value.isRecordingVideo,
                                  controller!.value.isRecordingPaused,
                                )) {
                                  (false, _, _) => cameraThemeData.imageCapture,
                                  (true, false, _) =>
                                    cameraThemeData.videoRecordingStart,
                                  (true, true, false) =>
                                    cameraThemeData.videoRecordingPause,
                                  (true, true, true) =>
                                    cameraThemeData.videoRecordingResume,
                                },
                                onPressed: switch ((
                                  cameraMode.isVideo,
                                  controller!.value.isRecordingVideo,
                                  controller!.value.isRecordingPaused,
                                )) {
                                  (false, _, _) => takePicture,
                                  (true, false, _) => startVideoRecording,
                                  (true, true, false) => pauseVideoRecording,
                                  (true, true, true) => resumeVideoRecording,
                                },
                              ),
                            ),
                            Expanded(
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: RotatedBox(
                                  quarterTurns: quarterTurns,
                                  child: widget.previewWidget,
                                ),
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
          const SizedBox(
            height: 16,
          ),
        ],
      ),
    );
  }

  Widget _cameraPreviewWidget() {
    final cameraController = controller;

    if (cameraController == null || !cameraController.value.isInitialized) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    } else {
      return Listener(
        onPointerDown: (_) => _pointers++,
        onPointerUp: (_) => _pointers--,
        child: CameraPreview(
          controller!,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onScaleStart: _handleScaleStart,
                onScaleUpdate: _handleScaleUpdate,
                onTapDown: (details) => onViewFinderTap(details, constraints),
              );
            },
          ),
        ),
      );
    }
  }

  void _handleScaleStart(ScaleStartDetails details) {
    _baseScale = _currentScale;
  }

  Future<void> _handleScaleUpdate(ScaleUpdateDetails details) async {
    // When there are not exactly two fingers on screen don't scale
    if (controller == null || _pointers != 2) {
      return;
    }

    _currentScale = (_baseScale * details.scale).clamp(
      _minAvailableZoom,
      _maxAvailableZoom,
    );

    await controller!.setZoomLevel(_currentScale);
  }

  void showInSnackBar(String message) {
    /* ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message))); */
  }

  void onViewFinderTap(TapDownDetails details, BoxConstraints constraints) {
    /* if (controller == null) {
      return;
    }

    final cameraController = controller!;

    final offset = Offset(
      details.localPosition.dx / constraints.maxWidth,
      details.localPosition.dy / constraints.maxHeight,
    );
    try {
      cameraController
        ..setExposurePoint(offset)
        ..setFocusPoint(offset);
    } catch (e) {
      /** */
    } */
  }

  CameraDescription get backCamera => widget.cameras
      .where(
        (e) => e.lensDirection == CameraLensDirection.back,
      )
      .toList()[config.defaultBackCameraIndex];
  CameraDescription get frontCamera => widget.cameras
      .where(
        (e) => e.lensDirection == CameraLensDirection.front,
      )
      .toList()[config.defaultFrontCameraIndex];

  Future<void> swapFrontBack({
    bool restore = false,
  }) async {
    if (restore) {
      currDescription =
          controller?.description ?? currDescription ?? backCamera;
    } else {
      if (currDescription == null) {
        currDescription = backCamera;
      } else {
        currDescription = currDescription == backCamera
            ? frontCamera
            : backCamera;
      }
    }

    if (controller != null) {
      await controller!.setDescription(currDescription!);
      final cameraController = controller!;
      try {
        await cameraController.initialize();
        await Future.wait(<Future<Object?>>[
          // The exposure mode is currently not supported on the web.
          ...!kIsWeb
              ? <Future<Object?>>[
                  cameraController.getMinExposureOffset().then(
                    (value) => minAvailableExposureOffset = value,
                  ),
                  cameraController.getMaxExposureOffset().then(
                    (value) => maxAvailableExposureOffset = value,
                  ),
                ]
              : <Future<Object?>>[],
          cameraController.getMaxZoomLevel().then((value) {
            _maxAvailableZoom = value;
            return null;
          }),
          cameraController.getMinZoomLevel().then(
            (value) => _minAvailableZoom = value,
          ),
        ]);
      } on CameraException catch (e) {
        switch (e.code) {
          case 'CameraAccessDenied':
            showInSnackBar('You have denied camera access.');
          case 'CameraAccessDeniedWithoutPrompt':
            // iOS only
            showInSnackBar(
              'Please go to Settings app to enable camera access.',
            );
          case 'CameraAccessRestricted':
            // iOS only
            showInSnackBar('Camera access is restricted.');
          case 'AudioAccessDenied':
            showInSnackBar('You have denied audio access.');
          case 'AudioAccessDeniedWithoutPrompt':
            // iOS only
            showInSnackBar('Please go to Settings app to enable audio access.');
          case 'AudioAccessRestricted':
            // iOS only
            showInSnackBar('Audio access is restricted.');
          default:
            showInSnackBar(e.toString());
        }
      }
      setState(() {});
    } else {
      return initializeCameraController(currDescription!);
    }
  }

  Future<void> initializeCameraController(
    CameraDescription cameraDescription,
  ) async {
    final prevCamera = controller;
    final cameraController = CameraController(
      cameraDescription,
      config.resolutionPreset,
      enableAudio: config.enableAudio,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    controller = cameraController;
    await prevCamera?.dispose();

    // If the controller is updated then update the UI.
    cameraController.addListener(() {
      if (mounted) {
        setState(() {});
      }
      if (cameraController.value.hasError) {
        showInSnackBar(
          'Camera error ${cameraController.value.errorDescription}',
        );
      }
    });

    try {
      await cameraController.initialize();
      await Future.wait(<Future<Object?>>[
        // The exposure mode is currently not supported on the web.
        ...!kIsWeb
            ? <Future<Object?>>[
                cameraController.getMinExposureOffset().then(
                  (value) => minAvailableExposureOffset = value,
                ),
                cameraController.getMaxExposureOffset().then(
                  (value) => maxAvailableExposureOffset = value,
                ),
              ]
            : <Future<Object?>>[],
        cameraController.getMaxZoomLevel().then((value) {
          _maxAvailableZoom = value;
          return null;
        }),
        cameraController.getMinZoomLevel().then(
          (value) => _minAvailableZoom = value,
        ),
      ]);
    } on CameraException catch (e) {
      switch (e.code) {
        case 'CameraAccessDenied':
          showInSnackBar('You have denied camera access.');
        case 'CameraAccessDeniedWithoutPrompt':
          // iOS only
          showInSnackBar('Please go to Settings app to enable camera access.');
        case 'CameraAccessRestricted':
          // iOS only
          showInSnackBar('Camera access is restricted.');
        case 'AudioAccessDenied':
          showInSnackBar('You have denied audio access.');
        case 'AudioAccessDeniedWithoutPrompt':
          // iOS only
          showInSnackBar('Please go to Settings app to enable audio access.');
        case 'AudioAccessRestricted':
          // iOS only
          showInSnackBar('Audio access is restricted.');
        default:
          showInSnackBar(e.toString());
      }
    }

    if (mounted) {
      setState(() {});
    }
  }

  int getQuarterTurns(DeviceOrientation oritentation) {
    final turns = <DeviceOrientation, int>{
      DeviceOrientation.portraitUp: 0,
      DeviceOrientation.landscapeRight: 3,
      DeviceOrientation.portraitDown: 2,
      DeviceOrientation.landscapeLeft: 1,
    };
    return turns[oritentation]!;
  }

  DeviceOrientation getApplicableOrientation(CameraController controller) {
    return controller.value.isRecordingVideo
        ? controller.value.recordingOrientation!
        : (controller.value.previewPauseOrientation ??
              controller.value.lockedCaptureOrientation ??
              controller.value.deviceOrientation);
  }

  void startVideoRecording() {
    unawaited(
      controller!.onStartVideoRecording(
        onError: widget.onError,
        onSuccess: () {
          if (mounted) {
            setState(() {
              isPaused = false;
              _isRecordingInProgress = true;
              recordingDuration = 0;
            });
            timer = Timer.periodic(const Duration(seconds: 1), (timer) {
              if (!isPaused) {
                setState(() {
                  recordingDuration++;
                });
              }
            });
          }
        },
      ),
    );
  }

  void stopVideoRecording() => controller!.onStopVideoRecording(
    onError: widget.onError,
    onSuccess: (videoFilePath) {
      if (mounted) {
        widget.onCapture(videoFilePath, isVideo: true);
        timer?.cancel();

        setState(() {
          _isRecordingInProgress = false;
          isPaused = false;
          recordingDuration = 0;
        });
      }
    },
  );

  void pauseVideoRecording() {
    unawaited(
      controller!.onPauseVideoRecording(
        onError: widget.onError,
        onSuccess: () {
          if (mounted) {
            setState(() {
              isPaused = true;
            });
          }
        },
      ),
    );
  }

  void resumeVideoRecording() {
    unawaited(
      controller!.onResumeVideoRecording(
        onError: widget.onError,
        onSuccess: () {
          if (mounted) {
            setState(() {
              isPaused = false;
            });
          }
        },
      ),
    );
  }

  void takePicture() {
    unawaited(
      controller!.onTakePicture(
        onError: widget.onError,
        onSuccess: (imageFilePath) {
          if (mounted) {
            widget.onCapture(imageFilePath, isVideo: false);
          }
        },
      ),
    );
  }

  Widget exposureModeSettings(CameraController? controller) {
    return Builder(
      builder: (context) {
        final isAutoSelected =
            controller?.value.exposureMode == ExposureMode.auto;
        final isLockedSelected =
            controller?.value.exposureMode == ExposureMode.locked;
        final selectedColor = ShadTheme.of(context).colorScheme.primary;
        final unselectedColor = ShadTheme.of(
          context,
        ).colorScheme.mutedForeground;
        return Column(
          children: <Widget>[
            const Center(
              child: Text('Exposure Mode'),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                ShadButton.ghost(
                  onPressed: () =>
                      onSetExposureModeButtonPressed(ExposureMode.auto),
                  onLongPress: controller == null
                      ? null
                      : () {
                          unawaited(controller.setExposurePoint(null));
                        },
                  child: Text(
                    'AUTO',
                    style: TextStyle(
                      color: isAutoSelected ? selectedColor : unselectedColor,
                    ),
                  ),
                ),
                ShadButton.ghost(
                  onPressed: () =>
                      onSetExposureModeButtonPressed(ExposureMode.locked),
                  child: Text(
                    'LOCKED',
                    style: TextStyle(
                      color: isLockedSelected ? selectedColor : unselectedColor,
                    ),
                  ),
                ),
                ShadButton.ghost(
                  onPressed: () {
                    unawaited(setExposureOffset(0));
                  },
                  child: Text(
                    'RESET OFFSET',
                    style: TextStyle(color: unselectedColor),
                  ),
                ),
              ],
            ),
            const Center(
              child: Text('Exposure Offset'),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Text(minAvailableExposureOffset.toString()),
                Slider(
                  value: currentExposureOffset,
                  min: minAvailableExposureOffset,
                  max: maxAvailableExposureOffset,
                  label: currentExposureOffset.toString(),
                  onChanged:
                      minAvailableExposureOffset == maxAvailableExposureOffset
                      ? null
                      : setExposureOffset,
                ),
                Text(maxAvailableExposureOffset.toString()),
              ],
            ),
            const SizedBox(height: 16),
            ShadButton(onPressed: closeSettings, child: const Text('Close')),
          ],
        );
      },
    );
  }

  void onSetExposureModeButtonPressed(ExposureMode mode) {
    unawaited(
      setExposureMode(mode).then((_) {
        if (mounted) {
          setState(() {});
        }
        // showInSnackBar(
        // 'Exposure mode set to ${mode.toString().split('.').last}');
      }),
    );
  }

  Future<void> setExposureMode(ExposureMode mode) async {
    if (controller == null) {
      return;
    }

    try {
      await controller!.setExposureMode(mode);
    } on CameraException catch (e) {
      widget.onError?.call('setExposureMode failed.', error: e);
    }
  }

  Future<void> setExposureOffset(double offset) async {
    if (controller == null) {
      return;
    }
    currentExposureOffset = offset;
    if (mounted) {
      setState(() {});
    }

    try {
      await controller!.setExposureOffset(offset);
    } /* on CameraException  */ catch (e) {
      widget.onError?.call('setExposureOffset failed.', error: e);
    }
  }

  Widget focusModeSettings(CameraController? controller) {
    return Builder(
      builder: (context) {
        final isAutoSelected = controller?.value.focusMode == FocusMode.auto;
        final isLockedSelected =
            controller?.value.focusMode == FocusMode.locked;
        final selectedColor = ShadTheme.of(context).colorScheme.primary;
        final unselectedColor = ShadTheme.of(
          context,
        ).colorScheme.mutedForeground;
        return Column(
          children: <Widget>[
            const Center(
              child: Text('Focus Mode'),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                ShadButton.ghost(
                  onPressed: controller != null
                      ? () => onSetFocusModeButtonPressed(FocusMode.auto)
                      : null,
                  onLongPress: () {
                    if (controller != null) {
                      unawaited(controller.setFocusPoint(null));
                    }
                  },
                  child: Text(
                    'AUTO',
                    style: TextStyle(
                      color: isAutoSelected ? selectedColor : unselectedColor,
                    ),
                  ),
                ),
                ShadButton.ghost(
                  onPressed: controller != null
                      ? () => onSetFocusModeButtonPressed(FocusMode.locked)
                      : null,
                  child: Text(
                    'LOCKED',
                    style: TextStyle(
                      color: isLockedSelected ? selectedColor : unselectedColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ShadButton(onPressed: closeSettings, child: const Text('Close')),
          ],
        );
      },
    );
  }

  void onSetFocusModeButtonPressed(FocusMode mode) {
    unawaited(
      setFocusMode(mode).then((_) {
        if (mounted) {
          setState(() {});
        }
        //showInSnackBar('Focus mode set to ${mode.toString().split('.').last}');
      }),
    );
  }

  Future<void> setFocusMode(FocusMode mode) async {
    if (controller == null) {
      return;
    }

    try {
      await controller!.setFocusMode(mode);
    } /* on CameraException  */ catch (e) {
      widget.onError?.call('setFocusMode failed.', error: e);
    }
  }

  Widget cameraSelector(List<CameraDescription> cameras) {
    final cameraThemeData = CameraTheme.of(context).themeData;
    final headerStyle = ShadTheme.of(context).textTheme.large.copyWith(
      fontWeight: FontWeight.bold,
    );
    final bodyStyle = ShadTheme.of(context).textTheme.p;
    final primaryColor = ShadTheme.of(context).colorScheme.primary;
    final mutedColor = ShadTheme.of(context).colorScheme.mutedForeground;

    Widget cameraToggleRow({
      required List<CameraDescription> cameras,
      required int selectedIndex,
      required Future<void> Function(int) onSelect,
    }) {
      return Wrap(
        spacing: 4,
        children: cameras.indexed.map((entry) {
          final (index, _) = entry;
          final isSelected = index == selectedIndex;
          return isSelected
              ? ShadButton(
                  onPressed: () => onSelect(index),
                  child: Text('Camera $index', style: bodyStyle),
                )
              : ShadButton.outline(
                  onPressed: () => onSelect(index),
                  child: Text(
                    'Camera $index',
                    style: bodyStyle.copyWith(color: mutedColor),
                  ),
                );
        }).toList(),
      );
    }

    final frontCameras = widget.cameras
        .where((e) => e.lensDirection == CameraLensDirection.front)
        .toList();
    final backCameras = widget.cameras
        .where((e) => e.lensDirection == CameraLensDirection.back)
        .toList();

    return Padding(
      padding: const EdgeInsets.all(4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: Text('Front Camera:', style: headerStyle),
              ),
              cameraToggleRow(
                cameras: frontCameras,
                selectedIndex: config.defaultFrontCameraIndex,
                onSelect: (index) async {
                  if (index != config.defaultFrontCameraIndex) {
                    config = config.copyWith(defaultFrontCameraIndex: index);
                    await config.saveConfig();
                  }
                  await initializeCameraController(frontCamera);
                },
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: Text('Back Camera:', style: headerStyle),
              ),
              cameraToggleRow(
                cameras: backCameras,
                selectedIndex: config.defaultBackCameraIndex,
                onSelect: (index) async {
                  if (index != config.defaultBackCameraIndex) {
                    config = config.copyWith(defaultBackCameraIndex: index);
                    await config.saveConfig();
                  }
                  await initializeCameraController(backCamera);
                },
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text('Image Resolution:', style: headerStyle),
          ),
          Wrap(
            spacing: 4,
            children: ResolutionPreset.values.map((preset) {
              final isSelected = preset == config.resolutionPreset;
              return isSelected
                  ? ShadButton(
                      onPressed: () async {
                        if (preset != config.resolutionPreset) {
                          config = config.copyWith(resolutionPreset: preset);
                          await config.saveConfig();
                          await initializeCameraController(backCamera);
                        }
                      },
                      child: Text(preset.name, style: bodyStyle),
                    )
                  : ShadButton.outline(
                      onPressed: () async {
                        config = config.copyWith(resolutionPreset: preset);
                        await config.saveConfig();
                        await initializeCameraController(backCamera);
                      },
                      child: Text(
                        preset.name,
                        style: bodyStyle.copyWith(color: mutedColor),
                      ),
                    );
            }).toList(),
          ),
          if (controller?.value.previewSize != null)
            Text(
              'Current Resolution ${controller!.value.previewSize!.width} '
              ' x ${controller!.value.previewSize!.height}',
              style: bodyStyle,
            ),
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: Text('Audio', style: headerStyle),
              ),
              CircularButton(
                icon: config.enableAudio
                    ? cameraThemeData.recordingAudioOn
                    : cameraThemeData.recordingAudioOff,
                hasDecoration: false,
                foregroundColor: config.enableAudio ? primaryColor : mutedColor,
                onPressed: () async {
                  config = config.copyWith(
                    enableAudio: !config.enableAudio,
                  );
                  await config.saveConfig();
                  await initializeCameraController(
                    currDescription ?? backCamera,
                  );
                },
              ),
              if (!config.enableAudio) const Text('(Muted)'),
            ],
          ),
          const SizedBox(height: 16),
          ShadButton(onPressed: closeSettings, child: const Text('Close')),
        ],
      ),
    );
  }

  Widget audioMute() {
    final cameraThemeData = CameraTheme.of(context).themeData;
    return CircularButton(
      icon: config.enableAudio
          ? cameraThemeData.recordingAudioOn
          : cameraThemeData.recordingAudioOff,
      hasDecoration: false,
      foregroundColor: config.enableAudio
          ? null
          : ShadTheme.of(context).colorScheme.destructive,
      onPressed: _isRecordingInProgress
          ? null
          : () async {
              config = config.copyWith(
                enableAudio: !config.enableAudio,
              );
              await config.saveConfig();
              await initializeCameraController(currDescription ?? backCamera);
            },
    );
  }

  String formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:'
          '${minutes.toString().padLeft(2, '0')}:'
          '${secs.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:'
          '${secs.toString().padLeft(2, '0')}';
    }
  }
}
