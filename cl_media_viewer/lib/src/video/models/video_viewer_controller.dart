import 'dart:async';
import 'dart:io';

import 'package:video_player/video_player.dart';

/// Abstract controller interface for video playback.
///
/// This interface allows the video viewer widget to work with any
/// video controller implementation. The widget doesn't manage controller
/// lifecycle - that's the consumer's responsibility.
abstract class VideoViewerController {
  /// Initialize the controller with a video URI.
  ///
  /// Supported schemes:
  /// - `file://` - Local file
  /// - `http://`, `https://` - Network URL
  /// - `asset:` - Asset file (e.g., `asset:assets/video.mp4`)
  Future<void> initialize(Uri uri);

  /// Dispose resources.
  Future<void> dispose();

  /// Start or resume playback.
  Future<void> play();

  /// Pause playback.
  Future<void> pause();

  /// Seek to a specific position.
  Future<void> seekTo(Duration position);

  /// Set the volume (0.0 to 1.0).
  Future<void> setVolume(double volume);

  /// Set whether to loop the video.
  Future<void> setLooping(bool looping);

  /// Whether the controller has been initialized.
  bool get isInitialized;

  /// Whether the video is currently playing.
  bool get isPlaying;

  /// Whether the video is currently buffering.
  bool get isBuffering;

  /// Whether playback has completed.
  bool get isCompleted;

  /// Current playback position.
  Duration get position;

  /// Total duration of the video.
  Duration get duration;

  /// Aspect ratio of the video (width / height).
  double get aspectRatio;

  /// Current volume (0.0 to 1.0).
  double get volume;

  /// Whether the video is looping.
  bool get isLooping;

  /// The underlying video_player controller for rendering.
  /// May be null if not initialized.
  VideoPlayerController? get videoPlayerController;

  /// Stream that emits when the controller state changes.
  /// Subscribe to this stream to rebuild UI on state changes.
  Stream<void> get onStateChanged;

  /// The current URI being played.
  Uri? get uri;
}

/// Default implementation of [VideoViewerController] using the video_player package.
///
/// This implementation manages a single [VideoPlayerController] and exposes
/// its state through the [VideoViewerController] interface.
///
/// Example usage:
/// ```dart
/// final controller = DefaultVideoViewerController();
/// await controller.initialize(Uri.parse('asset:assets/video.mp4'));
/// await controller.play();
/// // ...
/// await controller.dispose();
/// ```
class DefaultVideoViewerController implements VideoViewerController {
  VideoPlayerController? _controller;
  Uri? _uri;
  final StreamController<void> _stateController =
      StreamController<void>.broadcast();
  bool _disposed = false;

  @override
  Future<void> initialize(Uri uri) async {
    if (_disposed) {
      throw StateError('Cannot initialize a disposed controller');
    }

    // Dispose existing controller if any
    await _disposeInternal();

    _uri = uri;

    try {
      if (uri.scheme == 'file') {
        final path = uri.toFilePath();
        if (!File(path).existsSync()) {
          throw FileSystemException('File not found', path);
        }
        _controller = VideoPlayerController.file(File(path));
      } else if (uri.scheme == 'asset') {
        _controller = VideoPlayerController.asset(uri.path);
      } else if (['http', 'https'].contains(uri.scheme)) {
        // Detect HLS streams and provide format hint
        final isHls = uri.path.endsWith('.m3u8') ||
            uri.queryParameters['format'] == 'hls';
        _controller = VideoPlayerController.networkUrl(
          uri,
          formatHint: isHls ? VideoFormat.hls : null,
        );
      } else {
        throw ArgumentError('Unsupported URI scheme: ${uri.scheme}');
      }

      await _controller!.initialize();
      _controller!.addListener(_onControllerStateChanged);
      _notifyStateChanged();
    } catch (e) {
      await _disposeInternal();
      rethrow;
    }
  }

  Future<void> _disposeInternal() async {
    final controller = _controller;
    _controller = null;
    _uri = null;

    if (controller != null) {
      controller.removeListener(_onControllerStateChanged);
      await controller.pause();
      await controller.dispose();
    }
  }

  void _onControllerStateChanged() {
    if (!_disposed) {
      _notifyStateChanged();
    }
  }

  void _notifyStateChanged() {
    if (!_stateController.isClosed) {
      _stateController.add(null);
    }
  }

  @override
  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;

    await _disposeInternal();
    await _stateController.close();
  }

  @override
  Future<void> play() async {
    await _controller?.play();
  }

  @override
  Future<void> pause() async {
    await _controller?.pause();
  }

  @override
  Future<void> seekTo(Duration position) async {
    await _controller?.seekTo(position);
  }

  @override
  Future<void> setVolume(double volume) async {
    await _controller?.setVolume(volume.clamp(0.0, 1.0));
  }

  @override
  Future<void> setLooping(bool looping) async {
    await _controller?.setLooping(looping);
  }

  @override
  bool get isInitialized => _controller?.value.isInitialized ?? false;

  @override
  bool get isPlaying => _controller?.value.isPlaying ?? false;

  @override
  bool get isBuffering => _controller?.value.isBuffering ?? false;

  @override
  bool get isCompleted => _controller?.value.isCompleted ?? false;

  @override
  Duration get position => _controller?.value.position ?? Duration.zero;

  @override
  Duration get duration => _controller?.value.duration ?? Duration.zero;

  @override
  double get aspectRatio => _controller?.value.aspectRatio ?? 16 / 9;

  @override
  double get volume => _controller?.value.volume ?? 1.0;

  @override
  bool get isLooping => _controller?.value.isLooping ?? false;

  @override
  VideoPlayerController? get videoPlayerController => _controller;

  @override
  Stream<void> get onStateChanged => _stateController.stream;

  @override
  Uri? get uri => _uri;

  @override
  String toString() =>
      'DefaultVideoViewerController(uri: $_uri, initialized: $isInitialized)';
}
