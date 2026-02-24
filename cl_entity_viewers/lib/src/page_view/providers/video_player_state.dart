import 'dart:io';

import 'package:cl_extensions/cl_extensions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';

import '../models/video_player_controls.dart';
import '../models/video_player_state.dart';
import 'universal_config.dart';
import 'uri_config.dart';

class VideoPlayerNotifier extends AutoDisposeAsyncNotifier<VideoPlayerState>
    with CLLogger
    implements VideoPlayerControls {
  VideoPlayerNotifier();
  VideoPlayerController? _pendingController;
  int _currentLoadSequence = 0;

  /// All video operations are serialized through this chain.
  /// This is the root design fix for the "used after being disposed" error.
  Future<void> _pendingOperation = Future.value();

  @override
  String get logPrefix => 'VideoPlayer';

  /// Enqueue an operation to run after any in-progress operation completes.
  Future<void> _enqueue(Future<void> Function() op) {
    return _pendingOperation = _pendingOperation.then((_) => op()).catchError((
      e,
      st,
    ) {
      log('Enqueued operation failed: $e', error: e, stackTrace: st);
    });
  }

  @override
  Future<VideoPlayerState> build() async {
    ref.onDispose(() {
      // Synchronously clear state to prevent any pending UI callbacks
      // from seeing a disposed controller.
      state = const AsyncValue.loading();
      dispose();
    });
    debugPrint(
      '*** ANTIGRAVITY VIDEO PLAYER VERSION 2.2 (RESTORED + STABILITY FIX) ***',
    );
    log('Provider built, awaiting first video');
    return const VideoPlayerState();
  }

  Future<void> dispose() async {
    // Participating in the queue ensures we don't dispose while a setVideo is running.
    return _enqueue(() async {
      log('dispose() started in queue');
      final controller = state.value?.controller;
      final pending = _pendingController;
      _pendingController = null;

      if (controller != null) {
        log(
          'dispose: cleaning up active controller [id=${controller.hashCode}]',
        );
        controller.removeListener(timestampUpdater);
        controller.removeListener(statusListener);
        state = const AsyncValue.loading();
        try {
          await controller.pause();
          await controller.dispose();
        } catch (e) {
          log('dispose active failed: $e');
        }
      }

      if (pending != null && pending != controller) {
        log('dispose: cleaning up pending controller [id=${pending.hashCode}]');
        try {
          await pending.pause();
          await pending.dispose();
        } catch (e) {
          log('dispose pending failed: $e');
        }
      }
    });
  }

  @override
  Future<void> resetVideo({required bool autoPlay}) {
    return _enqueue(() async {
      if (state.value?.path != null) {
        log('resetVideo: path=${state.value!.path}');
        await _setVideoInternal(
          state.value!.path!,
          autoPlay: autoPlay,
          forced: true,
        );
      }
    });
  }

  @override
  Future<void> setVideo(Uri uri, {bool autoPlay = true, bool forced = false}) {
    log('setVideo() enqueuing uri=$uri forced=$forced');
    return _enqueue(
      () => _setVideoInternal(uri, autoPlay: autoPlay, forced: forced),
    );
  }

  Future<void> _setVideoInternal(
    Uri uri, {
    required bool autoPlay,
    required bool forced,
  }) async {
    final currentState = state;
    final isAlreadyActive =
        !currentState.isLoading &&
        currentState.value?.path == uri &&
        currentState.value?.controller != null;

    if (!forced && isAlreadyActive) {
      log('_setVideoInternal: skip (already active) uri=$uri');
      return;
    }

    final sequence = ++_currentLoadSequence;
    log('_setVideoInternal: START seq=$sequence uri=$uri');

    await _cleanupInternal(sequence: sequence);

    state = const AsyncValue.loading();
    log('_setVideoInternal: state=loading seq=$sequence');

    try {
      VideoPlayerController? controller;

      if (uri.scheme == 'file') {
        final path = uri.toFilePath();
        if (!File(path).existsSync()) {
          throw FileSystemException('missing file', path);
        }

        controller = VideoPlayerController.file(File(path));
      } else if (['http', 'https'].contains(uri.scheme)) {
        controller = VideoPlayerController.networkUrl(
          uri,
          formatHint: VideoFormat.hls,
          videoPlayerOptions: VideoPlayerOptions(
            allowBackgroundPlayback: false,
          ),
        );
      } else {
        throw Exception('not supported');
      }
      if (sequence != _currentLoadSequence) {
        log(
          '_setVideoInternal: stale after controller create, disposing seq=$sequence',
        );
        await controller.dispose();
        return;
      }

      _pendingController = controller;
      log(
        '_setVideoInternal: created controller [id=${controller.hashCode}] seq=$sequence, initializing...',
      );
      final universalConfig = await ref.read(universalConfigProvider.future);
      final uriConfig = await ref.read(uriConfigurationProvider(uri).future);

      await controller.initialize();

      if (sequence != _currentLoadSequence) {
        log(
          '_setVideoInternal: stale after initialize, disposing seq=$sequence',
        );
        if (_pendingController == controller) _pendingController = null;
        await controller.dispose();
        return;
      }

      if (!controller.value.isInitialized) {
        throw Exception(
          'VideoPlayerController.initialize() completed but controller reports not initialized',
        );
      }

      _pendingController = null;
      log(
        '_setVideoInternal: initialized [id=${controller.hashCode}], configuring... seq=$sequence',
      );
      await controller.setVolume(universalConfig.audioVolume);
      await controller.seekTo(uriConfig.lastKnownPlayPosition);
      await controller.setLooping(true); // FIXME: [LATER] from configuration

      if (autoPlay && !universalConfig.isManuallyPaused) {
        log('_setVideoInternal: auto-playing seq=$sequence');
        await controller.play();
      }
      final isHls =
          uri.path.endsWith('.m3u8') ||
          uri.queryParameters['format'] == 'hls' ||
          (['http', 'https'].contains(uri.scheme) &&
              !uri.path.contains('download'));

      controller.addListener(timestampUpdater);
      controller.addListener(statusListener);

      state = AsyncValue.data(
        VideoPlayerState(
          controller: controller,
          path: uri,
          isInitialized: true,
          isBuffering: controller.value.isBuffering,
          isHls: isHls,
        ),
      );

      log(
        '_setVideoInternal: DONE state=data [id=${controller.hashCode}] seq=$sequence',
      );
    } catch (error, stackTrace) {
      log(
        '_setVideoInternal: ERROR seq=$sequence: $error',
        error: error,
        stackTrace: stackTrace,
      );
      if (sequence == _currentLoadSequence) {
        state = AsyncValue.error(error, stackTrace);
      }
      _pendingController?.dispose();
      _pendingController = null;
    }
  }

  Future<void> _cleanupInternal({int? sequence}) async {
    final controller = state.value?.controller;
    final pending = _pendingController;
    _pendingController = null;

    final seqTag = sequence != null ? ' [seq=$sequence]' : '';

    if (controller != null) {
      log('_cleanupInternal$seqTag: disposing [id=${controller.hashCode}]');
      controller.removeListener(timestampUpdater);
      controller.removeListener(statusListener);

      // Clear state to Data(empty) to ensure "isActiveUri" returns false. v2.2
      state = AsyncValue.data(const VideoPlayerState());

      try {
        await controller.pause();
        await controller.dispose();
      } catch (e) {
        log('_cleanupInternal pause/dispose failed: $e');
      }
    }

    if (pending != null && pending != controller) {
      log(
        '_cleanupInternal$seqTag: disposing pending [id=${pending.hashCode}]',
      );
      try {
        await pending.pause();
        await pending.dispose();
      } catch (e) {
        log('_cleanupInternal pending failed: $e');
      }
    }
  }

  Future<void> timestampUpdater() async {
    if (state.isLoading || state.value?.controller == null) return;
    final controller = state.value!.controller!;
    if (!controller.value.isInitialized) return;

    final uri = state.value!.path;
    if (uri == null) return;

    try {
      final position = await controller.position;
      if (state.isLoading || state.value?.controller != controller) return;
      if (position == null) return;

      final uriConfig = await ref.read(uriConfigurationProvider(uri).future);
      if (state.isLoading || state.value?.controller != controller) return;
      final lastKnownPosition = uriConfig.lastKnownPlayPosition;
      final diff = (position - lastKnownPosition).abs();

      if (diff > const Duration(seconds: 1)) {
        ref
            .read(uriConfigurationProvider(uri).notifier)
            .onChange(lastKnownPlayPosition: position);
      }
    } catch (e) {
      log('timestampUpdater: error: $e');
    }
  }

  void statusListener() {
    if (state.isLoading || state.value?.controller == null) return;
    final controller = state.value!.controller!;

    if (state.value!.isBuffering != controller.value.isBuffering) {
      state = AsyncValue.data(
        state.value!.copyWith(isBuffering: controller.value.isBuffering),
      );
    }
  }

  @override
  Future<void> removeVideo() {
    log('removeVideo() enqueuing');
    return _enqueue(() async {
      _currentLoadSequence++;
      await _cleanupInternal(sequence: _currentLoadSequence);
      // Ensure we end in a settled empty state. v2.2
      state = AsyncValue.data(const VideoPlayerState());
    });
  }

  @override
  Future<void> play() {
    return _enqueue(() async {
      ref.read(universalConfigProvider.notifier).isManuallyPaused = false;
      if (state.isLoading || state.value?.controller == null) return;
      final controller = state.value!.controller!;
      try {
        await controller.play();
      } catch (e) {
        log('play() failed: $e');
      }
    });
  }

  @override
  Future<void> pause() {
    return _enqueue(() async {
      ref.read(universalConfigProvider.notifier).isManuallyPaused = true;
      if (state.isLoading || state.value?.controller == null) return;
      final controller = state.value!.controller!;
      try {
        await controller.pause();
      } catch (e) {
        log('pause() failed: $e');
      }
    });
  }

  bool isActiveUri(Uri uri) {
    if (state.isLoading || state.value?.controller == null) return false;
    if (uri != state.value?.path) return false;

    return true;
  }

  @override
  Future<void> onPlayPause(
    Uri uri, {
    bool autoPlay = true,
    bool forced = false,
  }) {
    return _enqueue(() async {
      log('onPlayPause: uri=$uri');
      if (!isActiveUri(uri)) {
        log('onPlayPause: URI mismatch, calling _setVideoInternal');
        await _setVideoInternal(uri, autoPlay: autoPlay, forced: forced);
      }

      if (!isActiveUri(uri)) {
        log('onPlayPause skip: URI still mismatch');
        return;
      }

      final controller = state.value!.controller!;
      final videoplayerStatus = controller.value;

      if (videoplayerStatus.isCompleted) {
        final isLive = (videoplayerStatus.duration.inSeconds) > 10 * 60 * 60;
        if (isLive) {
          log('onPlayPause: resetting live stream');
          await _setVideoInternal(uri, autoPlay: autoPlay, forced: true);
        }
        final activeController = state.value?.controller;
        if (activeController != null) await activeController.play();
      } else if (videoplayerStatus.isPlaying) {
        ref.read(universalConfigProvider.notifier).isManuallyPaused = true;
        await controller.pause();
      } else {
        ref.read(universalConfigProvider.notifier).isManuallyPaused = false;
        await controller.play();
      }
    });
  }

  @override
  Uri? get uri => state.value?.path;

  @override
  Future<void> onAdjustVolume(double value) {
    return _enqueue(() async {
      final curr = await ref.read(universalConfigProvider.future);
      if (curr.lastKnownVolume != value) {
        await ref
            .read(universalConfigProvider.notifier)
            .onChange(lastKnownVolume: value, isAudioMuted: value != 0);
      }
      if (!state.isLoading && state.value?.controller != null) {
        await state.value!.controller!.setVolume(value);
      }
    });
  }

  @override
  Future<void> onToggleAudioMute() {
    return _enqueue(() async {
      final curr = await ref.read(universalConfigProvider.future);
      final mute = !curr.isAudioMuted;
      await ref
          .read(universalConfigProvider.notifier)
          .onChange(isAudioMuted: mute);
      if (!state.isLoading && state.value?.controller != null) {
        await state.value!.controller!.setVolume(
          mute ? 0 : curr.lastKnownVolume,
        );
      }
    });
  }

  @override
  Future<void> seekTo(Duration position) {
    return _enqueue(() async {
      if (!state.isLoading && state.value?.controller != null) {
        await state.value!.controller!.seekTo(position);
      }
    });
  }
}

final videoPlayerProvider =
    AsyncNotifierProvider.autoDispose<VideoPlayerNotifier, VideoPlayerState>(
      VideoPlayerNotifier.new,
    );
