import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final camerasProvider = FutureProvider<List<CameraDescription>>((ref) async {
  return availableCameras();
});
