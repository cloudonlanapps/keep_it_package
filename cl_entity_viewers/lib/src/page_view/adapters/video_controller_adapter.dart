import 'dart:async';

import 'package:cl_media_viewer/cl_media_viewer.dart';
import 'package:video_player/video_player.dart' as vp;

/// Adapts an existing [VideoPlayerController] to the [VideoViewerController] interface.
///
/// This adapter wraps a pre-existing video_player controller (managed externally,
/// e.g., by a Riverpod provider) and exposes it through the [VideoViewerController]
/// interface for use with [InteractiveVideoViewer].
///
/// The adapter does NOT manage the controller's lifecycle - the consumer is
/// responsible for initialization and disposal of the underlying controller.
class VideoControllerAdapter implements VideoViewerController {
  VideoControllerAdapter({
    required vp.VideoPlayerController controller,
    required Uri uri,
  })  : _controller = controller,
        _uri = uri {
    _controller.addListener(_onControllerStateChanged);
  }

  final vp.VideoPlayerController _controller;
  final Uri _uri;
  final StreamController<void> _stateController =
      StreamController<void>.broadcast();
  bool _disposed = false;

  void _onControllerStateChanged() {
    if (!_disposed && !_stateController.isClosed) {
      _stateController.add(null);
    }
  }

  @override
  Future<void> initialize(Uri uri) async {
    // This adapter wraps an already-initialized controller.
    // Initialization is handled externally.
    throw UnsupportedError(
      'VideoControllerAdapter wraps an existing controller. '
      'Initialize the underlying VideoPlayerController directly.',
    );
  }

  @override
  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;

    // Only remove listener if controller hasn't been disposed
    // The underlying controller is managed by Riverpod and may already be disposed
    try {
      _controller.removeListener(_onControllerStateChanged);
    } catch (_) {
      // Controller already disposed, ignore
    }
    await _stateController.close();

    // Note: We do NOT dispose the underlying controller.
    // The consumer (e.g., Riverpod provider) manages its lifecycle.
  }

  @override
  Future<void> play() async {
    await _controller.play();
  }

  @override
  Future<void> pause() async {
    await _controller.pause();
  }

  @override
  Future<void> seekTo(Duration position) async {
    await _controller.seekTo(position);
  }

  @override
  Future<void> setVolume(double volume) async {
    await _controller.setVolume(volume.clamp(0.0, 1.0));
  }

  @override
  Future<void> setLooping(bool looping) async {
    await _controller.setLooping(looping);
  }

  @override
  bool get isInitialized => _controller.value.isInitialized;

  @override
  bool get isPlaying => _controller.value.isPlaying;

  @override
  bool get isBuffering => _controller.value.isBuffering;

  @override
  bool get isCompleted => _controller.value.isCompleted;

  @override
  Duration get position => _controller.value.position;

  @override
  Duration get duration => _controller.value.duration;

  @override
  double get aspectRatio => _controller.value.aspectRatio;

  @override
  double get volume => _controller.value.volume;

  @override
  bool get isLooping => _controller.value.isLooping;

  @override
  vp.VideoPlayerController? get videoPlayerController => _controller;

  @override
  Stream<void> get onStateChanged => _stateController.stream;

  @override
  Uri? get uri => _uri;

  @override
  String toString() =>
      'VideoControllerAdapter(uri: $_uri, initialized: $isInitialized)';
}
