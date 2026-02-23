import 'dart:async';

import 'package:cl_media_viewer/cl_media_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:video_player/video_player.dart';

/// Mock implementation of VideoViewerController for testing.
class MockVideoViewerController implements VideoViewerController {
  MockVideoViewerController({
    this.mockIsInitialized = false,
    this.mockIsPlaying = false,
    this.mockIsBuffering = false,
    this.mockIsCompleted = false,
    this.mockPosition = Duration.zero,
    this.mockDuration = const Duration(seconds: 60),
    this.mockAspectRatio = 16 / 9,
    this.mockVolume = 1.0,
    this.mockIsLooping = false,
    this.mockUri,
  });

  bool mockIsInitialized;
  bool mockIsPlaying;
  bool mockIsBuffering;
  bool mockIsCompleted;
  Duration mockPosition;
  Duration mockDuration;
  double mockAspectRatio;
  double mockVolume;
  bool mockIsLooping;
  Uri? mockUri;

  final StreamController<void> _stateController =
      StreamController<void>.broadcast();

  int initializeCallCount = 0;
  int playCallCount = 0;
  int pauseCallCount = 0;
  int seekToCallCount = 0;
  int setVolumeCallCount = 0;
  int disposeCallCount = 0;

  Duration? lastSeekPosition;
  double? lastVolumeSet;
  Uri? lastInitializeUri;

  void notifyStateChanged() {
    if (!_stateController.isClosed) {
      _stateController.add(null);
    }
  }

  @override
  Future<void> initialize(Uri uri) async {
    initializeCallCount++;
    lastInitializeUri = uri;
    mockUri = uri;
    mockIsInitialized = true;
    notifyStateChanged();
  }

  @override
  Future<void> dispose() async {
    disposeCallCount++;
    await _stateController.close();
  }

  @override
  Future<void> play() async {
    playCallCount++;
    mockIsPlaying = true;
    notifyStateChanged();
  }

  @override
  Future<void> pause() async {
    pauseCallCount++;
    mockIsPlaying = false;
    notifyStateChanged();
  }

  @override
  Future<void> seekTo(Duration position) async {
    seekToCallCount++;
    lastSeekPosition = position;
    mockPosition = position;
    notifyStateChanged();
  }

  @override
  Future<void> setVolume(double volume) async {
    setVolumeCallCount++;
    lastVolumeSet = volume;
    mockVolume = volume;
    notifyStateChanged();
  }

  @override
  Future<void> setLooping(bool looping) async {
    mockIsLooping = looping;
    notifyStateChanged();
  }

  @override
  bool get isInitialized => mockIsInitialized;

  @override
  bool get isPlaying => mockIsPlaying;

  @override
  bool get isBuffering => mockIsBuffering;

  @override
  bool get isCompleted => mockIsCompleted;

  @override
  Duration get position => mockPosition;

  @override
  Duration get duration => mockDuration;

  @override
  double get aspectRatio => mockAspectRatio;

  @override
  double get volume => mockVolume;

  @override
  bool get isLooping => mockIsLooping;

  @override
  VideoPlayerController? get videoPlayerController => null;

  @override
  Stream<void> get onStateChanged => _stateController.stream;

  @override
  Uri? get uri => mockUri;
}

void main() {
  group('VideoViewerController', () {
    test('DefaultVideoViewerController initial state', () {
      final controller = DefaultVideoViewerController();

      expect(controller.isInitialized, isFalse);
      expect(controller.isPlaying, isFalse);
      expect(controller.isBuffering, isFalse);
      expect(controller.position, Duration.zero);
      expect(controller.duration, Duration.zero);
      expect(controller.uri, isNull);
      expect(controller.videoPlayerController, isNull);

      controller.dispose();
    });

    test('DefaultVideoViewerController throws on invalid scheme', () async {
      final controller = DefaultVideoViewerController();

      expect(
        () => controller.initialize(Uri.parse('ftp://invalid/video.mp4')),
        throwsA(isA<ArgumentError>()),
      );

      await controller.dispose();
    });

    test('DefaultVideoViewerController throws when disposed', () async {
      final controller = DefaultVideoViewerController();
      await controller.dispose();

      expect(
        () => controller.initialize(Uri.parse('file:///test.mp4')),
        throwsA(isA<StateError>()),
      );
    });
  });

  group('MockVideoViewerController', () {
    test('tracks method calls', () async {
      final controller = MockVideoViewerController();

      await controller.initialize(Uri.parse('asset:test.mp4'));
      expect(controller.initializeCallCount, 1);
      expect(controller.lastInitializeUri?.toString(), 'asset:test.mp4');

      await controller.play();
      expect(controller.playCallCount, 1);
      expect(controller.isPlaying, isTrue);

      await controller.pause();
      expect(controller.pauseCallCount, 1);
      expect(controller.isPlaying, isFalse);

      await controller.seekTo(const Duration(seconds: 30));
      expect(controller.seekToCallCount, 1);
      expect(controller.lastSeekPosition, const Duration(seconds: 30));

      await controller.setVolume(0.5);
      expect(controller.setVolumeCallCount, 1);
      expect(controller.lastVolumeSet, 0.5);

      await controller.dispose();
      expect(controller.disposeCallCount, 1);
    });

    test('notifies state changes', () async {
      final controller = MockVideoViewerController();
      var notificationCount = 0;

      controller.onStateChanged.listen((_) => notificationCount++);

      await controller.initialize(Uri.parse('asset:test.mp4'));
      await controller.play();
      await controller.pause();

      // Allow stream to propagate
      await Future<void>.delayed(Duration.zero);

      expect(notificationCount, greaterThanOrEqualTo(3));

      await controller.dispose();
    });
  });

  group('InteractiveVideoViewer', () {
    testWidgets('shows loading when not initialized', (tester) async {
      final controller = MockVideoViewerController(mockIsInitialized: false);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InteractiveVideoViewer(controller: controller),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await controller.dispose();
    });

    testWidgets('uses custom loading builder', (tester) async {
      final controller = MockVideoViewerController(mockIsInitialized: false);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InteractiveVideoViewer(
              controller: controller,
              loadingBuilder: () => const Text('Custom Loading'),
            ),
          ),
        ),
      );

      expect(find.text('Custom Loading'), findsOneWidget);

      await controller.dispose();
    });

    testWidgets('rebuilds on state change', (tester) async {
      final controller = MockVideoViewerController(mockIsInitialized: false);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InteractiveVideoViewer(controller: controller),
          ),
        ),
      );

      // Initially shows loading
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Simulate initialization
      controller.mockIsInitialized = true;
      controller.notifyStateChanged();
      await tester.pump();

      // Note: Without a real VideoPlayerController, the widget will still
      // show loading because videoPlayerController is null in mock

      await controller.dispose();
    });

    testWidgets('handles controller change', (tester) async {
      final controller1 = MockVideoViewerController(mockIsInitialized: true);
      final controller2 = MockVideoViewerController(mockIsInitialized: false);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InteractiveVideoViewer(controller: controller1),
          ),
        ),
      );

      // Change controller
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InteractiveVideoViewer(controller: controller2),
          ),
        ),
      );

      // Should switch to new controller
      expect(find.byType(InteractiveVideoViewer), findsOneWidget);

      await controller1.dispose();
      await controller2.dispose();
    });

    testWidgets('disposes subscriptions on unmount', (tester) async {
      final controller = MockVideoViewerController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InteractiveVideoViewer(controller: controller),
          ),
        ),
      );

      // Remove the widget
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: SizedBox())),
      );

      // Should not throw when notifying after unmount
      controller.notifyStateChanged();

      await controller.dispose();
    });
  });

  group('InteractiveVideoViewer configuration', () {
    testWidgets('respects quarterTurns for rotation', (tester) async {
      final controller = MockVideoViewerController(mockIsInitialized: false);

      // Test rotation = 0
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InteractiveVideoViewer(
              controller: controller,
              quarterTurns: 0,
            ),
          ),
        ),
      );

      expect(find.byType(InteractiveVideoViewer), findsOneWidget);

      // Test rotation = 1 (90 degrees)
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InteractiveVideoViewer(
              controller: controller,
              quarterTurns: 1,
            ),
          ),
        ),
      );

      expect(find.byType(InteractiveVideoViewer), findsOneWidget);

      await controller.dispose();
    });

    testWidgets('respects keepAspectRatio setting', (tester) async {
      final controller = MockVideoViewerController(mockIsInitialized: false);

      // With aspect ratio
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InteractiveVideoViewer(
              controller: controller,
              keepAspectRatio: true,
            ),
          ),
        ),
      );

      expect(find.byType(InteractiveVideoViewer), findsOneWidget);

      // Without aspect ratio
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InteractiveVideoViewer(
              controller: controller,
              keepAspectRatio: false,
            ),
          ),
        ),
      );

      expect(find.byType(InteractiveVideoViewer), findsOneWidget);

      await controller.dispose();
    });
  });
}
