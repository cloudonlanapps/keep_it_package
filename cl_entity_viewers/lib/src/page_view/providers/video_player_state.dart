import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';

import '../models/video_player_controls.dart';
import '../models/video_player_state.dart';
import 'universal_config.dart';
import 'uri_config.dart';

class VideoPlayerNotifier extends AutoDisposeAsyncNotifier<VideoPlayerState>
    implements VideoPlayerControls {
  VideoPlayerNotifier();
  VideoPlayerController? _pendingController;
  int _currentLoadSequence = 0;

  @override
  Future<VideoPlayerState> build() async {
    ref.onDispose(dispose);
    return const VideoPlayerState();
  }

  Future<void> dispose() async {
    final controller = state.value?.controller;
    final pending = _pendingController;
    _pendingController = null;

    if (controller != null) {
      controller.removeListener(timestampUpdater);
      controller.removeListener(statusListener);
      await controller.pause();
      await controller.dispose();
    }

    if (pending != null && pending != controller) {
      await pending.pause();
      await pending.dispose();
    }
  }

  @override
  Future<void> resetVideo({required bool autoPlay}) async {
    if (state.value?.path != null) {
      await setVideo(state.value!.path!, autoPlay: autoPlay, forced: true);
    }
  }

  @override
  Future<void> setVideo(
    Uri uri, {
    bool autoPlay = true,
    bool forced = false,
  }) async {
    if (!forced && state.value?.path == uri) return;

    // Increment sequence to invalidate any previous in-progress loads
    final sequence = ++_currentLoadSequence;

    // Aggressively cleanup current state and any pending controller from a previous race
    await _cleanupInternal();

    state = const AsyncValue.loading();

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
        await controller.dispose();
        return;
      }

      _pendingController = controller;
      final universalConfig = await ref.read(universalConfigProvider.future);
      final uriConfig = await ref.read(uriConfigurationProvider(uri).future);

      await controller.initialize();

      if (sequence != _currentLoadSequence) {
        await controller.dispose();
        return;
      }

      if (!controller.value.isInitialized) {
        throw Exception('Failed to load Video');
      }
      _pendingController = null;
      debugPrint(
        'VideoPlayer: Setting volume to ${universalConfig.audioVolume}',
      );
      await controller.setVolume(universalConfig.audioVolume);
      await controller.seekTo(uriConfig.lastKnownPlayPosition);
      await controller.setLooping(true); // FIXME: [LATER] from configuration

      if (autoPlay && !universalConfig.isManuallyPaused) {
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
    } catch (error, stackTrace) {
      if (sequence == _currentLoadSequence) {
        state = AsyncValue.error(error, stackTrace);
      }
      _pendingController?.dispose();
      _pendingController = null;
    }
  }

  Future<void> _cleanupInternal() async {
    final controller = state.value?.controller;
    final pending = _pendingController;
    _pendingController = null;

    if (controller != null) {
      controller.removeListener(timestampUpdater);
      controller.removeListener(statusListener);
      await controller.pause();
      await controller.dispose();
    }

    if (pending != null && pending != controller) {
      await pending.pause();
      await pending.dispose();
    }
  }

  Future<void> timestampUpdater() async {
    if (state.value == null || state.value!.controller == null) return;
    final controller = state.value!.controller!;
    if (!controller.value.isInitialized) return;

    final uri = state.value!.path;
    if (uri == null) return;

    try {
      final position = await controller.position;
      if (position == null) return;

      final uriConfig = await ref.read(uriConfigurationProvider(uri).future);
      final lastKnownPosition = uriConfig.lastKnownPlayPosition;
      final diff = (position - lastKnownPosition).abs();

      if (diff > const Duration(seconds: 1)) {
        ref
            .read(uriConfigurationProvider(uri).notifier)
            .onChange(lastKnownPlayPosition: position);
      }
    } catch (e) {
      debugPrint('VideoPlayer: Error in timestampUpdater: $e');
    }
  }

  void statusListener() {
    if (state.value == null || state.value!.controller == null) return;
    final controller = state.value!.controller!;

    if (state.value!.isBuffering != controller.value.isBuffering) {
      state = AsyncValue.data(
        state.value!.copyWith(isBuffering: controller.value.isBuffering),
      );
    }
  }

  @override
  Future<void> removeVideo() async {
    _currentLoadSequence++; // Invalidate pending loads
    await _cleanupInternal();
    state = const AsyncValue.loading();
  }

  @override
  Future<void> play() async {
    ref.read(universalConfigProvider.notifier).isManuallyPaused = false;

    return state.value?.controller?.play();
  }

  @override
  Future<void> pause() async {
    ref.read(universalConfigProvider.notifier).isManuallyPaused = true;
    return state.value?.controller?.pause();
  }

  bool isActiveUri(Uri uri) {
    if (state.value?.controller == null) {
      return false;
    }
    if (uri != state.value?.path) {
      return false;
    }

    return true;
  }

  @override
  Future<void> onPlayPause(
    Uri uri, {
    bool autoPlay = true,
    bool forced = false,
  }) async {
    if (!isActiveUri(uri)) {
      await setVideo(uri, autoPlay: autoPlay, forced: forced);
    }
    if (!isActiveUri(uri)) {
      throw Exception('Unexpcted, unable to register uri with the player');
    }
    final controller = state.value!.controller!;
    final videoplayerStatus = controller.value;
    if (videoplayerStatus.isCompleted) {
      final isLive = (videoplayerStatus.duration.inSeconds) > 10 * 60 * 60;
      if (isLive) {
        await ref
            .read(videoPlayerProvider.notifier)
            .resetVideo(autoPlay: autoPlay);
      }
      await play();
    } else if (videoplayerStatus.isPlaying) {
      await pause();
    } else {
      await play();
    }
  }

  @override
  Uri? get uri => state.value?.path;

  @override
  Future<void> onAdjustVolume(double value) async {
    final curr = await ref.read(universalConfigProvider.future);

    if (curr.lastKnownVolume != value) {
      await ref
          .read(universalConfigProvider.notifier)
          .onChange(lastKnownVolume: value, isAudioMuted: value != 0);
    }
    if (state.value?.controller != null) {
      final controller = state.value!.controller!;
      await controller.setVolume(curr.lastKnownVolume);
    }
  }

  @override
  Future<void> onToggleAudioMute() async {
    final curr = await ref.read(universalConfigProvider.future);
    final mute = !curr.isAudioMuted;

    await ref
        .read(universalConfigProvider.notifier)
        .onChange(isAudioMuted: mute);
    if (state.value?.controller != null) {
      final controller = state.value!.controller!;
      await controller.setVolume(mute ? 0 : curr.lastKnownVolume);
    }
  }

  @override
  Future<void> seekTo(Duration position) async {
    if (state.value?.controller != null) {
      final controller = state.value!.controller!;
      await controller.seekTo(position);
    }
  }
}

final videoPlayerProvider =
    AsyncNotifierProvider.autoDispose<VideoPlayerNotifier, VideoPlayerState>(
      VideoPlayerNotifier.new,
    );
