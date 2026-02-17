import 'package:cl_camera/cl_camera.dart';
import 'package:flutter/material.dart';

class SimpleCameraTheme extends CLCameraThemeData {
  const SimpleCameraTheme()
      : super(
          iconCamera: Icons.camera_alt,
          iconMicrophone: Icons.mic,
          iconLocation: Icons.location_on,
          imageCapture: Icons.camera,
          videoRecordingStart: Icons.videocam,
          videoRecordingPause: Icons.pause_circle,
          videoRecordingResume: Icons.play_circle,
          videoRecordingStop: Icons.stop_circle,
          flashModeOff: Icons.flash_off,
          flashModeAuto: Icons.flash_auto,
          flashModeAlways: Icons.flash_on,
          flashModeTorch: Icons.highlight,
          recordingAudioOn: Icons.mic,
          recordingAudioOff: Icons.mic_off,
          switchCamera: Icons.flip_camera_ios,
          exitCamera: Icons.close,
          invokeCamera: Icons.camera_alt,
          popMenuAnchor: Icons.more_vert,
          popMenuSelectedItem: Icons.check,
          cameraSettings: Icons.tune,
          pagePop: Icons.arrow_back,
          displayIconSize: 32,
        );
}
