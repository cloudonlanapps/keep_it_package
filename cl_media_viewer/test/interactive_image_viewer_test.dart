import 'package:cl_basic_types/cl_basic_types.dart';
import 'package:cl_media_viewer/cl_media_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('InteractiveFace', () {
    test('creates with required data', () {
      final faceData = FaceData(
        id: 1,
        bbox: (x1: 0.1, y1: 0.2, x2: 0.3, y2: 0.4),
        confidence: 0.95,
      );

      final face = InteractiveFace(data: faceData);

      expect(face.id, 1);
      expect(face.bbox.x1, 0.1);
      expect(face.bbox.y1, 0.2);
      expect(face.bbox.x2, 0.3);
      expect(face.bbox.y2, 0.4);
      expect(face.confidence, 0.95);
      expect(face.width, closeTo(0.2, 0.001));
      expect(face.height, closeTo(0.2, 0.001));
    });

    test('creates with callbacks', () {
      var tapped = false;
      var longPressed = false;
      Offset? tapPosition;
      Offset? longPressPosition;

      final face = InteractiveFace(
        data: FaceData(
          id: 1,
          bbox: (x1: 0.0, y1: 0.0, x2: 1.0, y2: 1.0),
          confidence: 1.0,
        ),
        onTap: (pos) {
          tapped = true;
          tapPosition = pos;
        },
        onLongPress: (pos) {
          longPressed = true;
          longPressPosition = pos;
        },
      );

      face.onTap?.call(const Offset(100, 200));
      expect(tapped, isTrue);
      expect(tapPosition, const Offset(100, 200));

      face.onLongPress?.call(const Offset(150, 250));
      expect(longPressed, isTrue);
      expect(longPressPosition, const Offset(150, 250));
    });
  });

  group('InteractiveImageData', () {
    test('creates with required fields', () {
      final imageData = InteractiveImageData(
        uri: Uri.parse('https://example.com/image.jpg'),
        width: 1920,
        height: 1080,
      );

      expect(imageData.width, 1920);
      expect(imageData.height, 1080);
      expect(imageData.aspectRatio, closeTo(1.78, 0.01));
      expect(imageData.faces, isEmpty);
    });

    test('creates with faces', () {
      final imageData = InteractiveImageData(
        uri: Uri.parse('https://example.com/image.jpg'),
        width: 1920,
        height: 1080,
        faces: [
          InteractiveFace(
            data: FaceData(
              id: 1,
              bbox: (x1: 0.25, y1: 0.25, x2: 0.5, y2: 0.5),
              confidence: 0.9,
            ),
          ),
        ],
      );

      expect(imageData.faces.length, 1);
      expect(imageData.faces[0].id, 1);
    });
  });

  group('InteractiveFaceBox', () {
    testWidgets('renders face box at correct position', (tester) async {
      final face = InteractiveFace(
        data: FaceData(
          id: 1,
          bbox: (x1: 0.25, y1: 0.25, x2: 0.75, y2: 0.75),
          confidence: 0.95,
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 400,
              child: Stack(
                children: [
                  InteractiveFaceBox(
                    face: face,
                    index: 0,
                    imageSize: const Size(400, 400),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      // Find the first positioned widget (the main face box container)
      final positioned =
          tester.widget<Positioned>(find.byType(Positioned).first);

      // Verify position (0.25 * 400 = 100)
      expect(positioned.left, 100);
      expect(positioned.top, 100);
      expect(positioned.width, 200); // (0.75 - 0.25) * 400
      expect(positioned.height, 200);
    });

    testWidgets('triggers onTap callback with position', (tester) async {
      var tapCount = 0;
      Offset? lastTapPosition;

      final face = InteractiveFace(
        data: FaceData(
          id: 1,
          bbox: (x1: 0.0, y1: 0.0, x2: 1.0, y2: 1.0),
          confidence: 0.95,
        ),
        onTap: (pos) {
          tapCount++;
          lastTapPosition = pos;
        },
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 200,
              height: 200,
              child: Stack(
                children: [
                  InteractiveFaceBox(
                    face: face,
                    index: 0,
                    imageSize: const Size(200, 200),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(InteractiveFaceBox));
      expect(tapCount, 1);
      expect(lastTapPosition, isNotNull);
    });

    testWidgets('triggers onLongPress callback with position', (tester) async {
      var longPressCount = 0;
      Offset? lastLongPressPosition;

      final face = InteractiveFace(
        data: FaceData(
          id: 1,
          bbox: (x1: 0.0, y1: 0.0, x2: 1.0, y2: 1.0),
          confidence: 0.95,
        ),
        onLongPress: (pos) {
          longPressCount++;
          lastLongPressPosition = pos;
        },
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 200,
              height: 200,
              child: Stack(
                children: [
                  InteractiveFaceBox(
                    face: face,
                    index: 0,
                    imageSize: const Size(200, 200),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.longPress(find.byType(InteractiveFaceBox));
      expect(longPressCount, 1);
      expect(lastLongPressPosition, isNotNull);
    });

    testWidgets('shows face number when enabled', (tester) async {
      final face = InteractiveFace(
        data: FaceData(
          id: 1,
          bbox: (x1: 0.0, y1: 0.0, x2: 1.0, y2: 1.0),
          confidence: 0.95,
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 200,
              height: 200,
              child: Stack(
                children: [
                  InteractiveFaceBox(
                    face: face,
                    index: 2, // 0-indexed, should show "3"
                    imageSize: const Size(200, 200),
                    showFaceNumber: true,
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      // Should show "3" (index + 1)
      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('hides face number when disabled', (tester) async {
      final face = InteractiveFace(
        data: FaceData(
          id: 1,
          bbox: (x1: 0.0, y1: 0.0, x2: 1.0, y2: 1.0),
          confidence: 0.95,
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 200,
              height: 200,
              child: Stack(
                children: [
                  InteractiveFaceBox(
                    face: face,
                    index: 0,
                    imageSize: const Size(200, 200),
                    showFaceNumber: false,
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.text('1'), findsNothing);
    });

    testWidgets('displays label when provided', (tester) async {
      final face = InteractiveFace(
        data: FaceData(
          id: 1,
          bbox: (x1: 0.0, y1: 0.0, x2: 1.0, y2: 1.0),
          confidence: 0.95,
        ),
        label: 'John Doe',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 200,
              height: 200,
              child: Stack(
                children: [
                  InteractiveFaceBox(
                    face: face,
                    index: 0,
                    imageSize: const Size(200, 200),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.text('John Doe'), findsOneWidget);
    });
  });

  group('InteractiveImageViewer', () {
    testWidgets('renders without faces', (tester) async {
      final imageData = InteractiveImageData(
        uri: Uri.parse('asset:test_assets/test_image.png'),
        width: 800,
        height: 600,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: InteractiveImageViewer(imageData: imageData)),
        ),
      );

      // Should render without error
      expect(find.byType(InteractiveImageViewer), findsOneWidget);
      expect(find.byType(InteractiveFaceBox), findsNothing);
    });

    testWidgets('renders with multiple faces', (tester) async {
      final imageData = InteractiveImageData(
        uri: Uri.parse('asset:test_assets/test_image.png'),
        width: 800,
        height: 600,
        faces: [
          InteractiveFace(
            data: FaceData(
              id: 1,
              bbox: (x1: 0.1, y1: 0.1, x2: 0.3, y2: 0.3),
              confidence: 0.9,
            ),
          ),
          InteractiveFace(
            data: FaceData(
              id: 2,
              bbox: (x1: 0.5, y1: 0.5, x2: 0.7, y2: 0.7),
              confidence: 0.85,
            ),
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: InteractiveImageViewer(imageData: imageData)),
        ),
      );

      expect(find.byType(InteractiveFaceBox), findsNWidgets(2));
    });

    testWidgets('triggers global onTap callback', (tester) async {
      var globalTapCount = 0;

      final imageData = InteractiveImageData(
        uri: Uri.parse('asset:test_assets/test_image.png'),
        width: 800,
        height: 600,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InteractiveImageViewer(
              imageData: imageData,
              onTap: () => globalTapCount++,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(GestureDetector).first);
      expect(globalTapCount, 1);
    });

    testWidgets('keyboard shortcut triggers face callback', (tester) async {
      var face1TapCount = 0;
      var face2TapCount = 0;

      final imageData = InteractiveImageData(
        uri: Uri.parse('asset:test_assets/test_image.png'),
        width: 800,
        height: 600,
        faces: [
          InteractiveFace(
            data: FaceData(
              id: 1,
              bbox: (x1: 0.1, y1: 0.1, x2: 0.3, y2: 0.3),
              confidence: 0.9,
            ),
            onTap: (_) => face1TapCount++,
          ),
          InteractiveFace(
            data: FaceData(
              id: 2,
              bbox: (x1: 0.5, y1: 0.5, x2: 0.7, y2: 0.7),
              confidence: 0.85,
            ),
            onTap: (_) => face2TapCount++,
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: InteractiveImageViewer(imageData: imageData)),
        ),
      );

      // Find the Focus widget that is a descendant of InteractiveImageViewer
      final focusFinder = find.descendant(
        of: find.byType(InteractiveImageViewer),
        matching: find.byType(Focus),
      );
      expect(focusFinder, findsOneWidget);

      // Get the FocusNode and request focus
      final focusWidget = tester.widget<Focus>(focusFinder);
      focusWidget.focusNode?.requestFocus();
      await tester.pump();

      // Press '1' to select first face
      await tester.sendKeyEvent(LogicalKeyboardKey.digit1);
      await tester.pump();
      expect(face1TapCount, 1);
      expect(face2TapCount, 0);

      // Press '2' to select second face
      await tester.sendKeyEvent(LogicalKeyboardKey.digit2);
      await tester.pump();
      expect(face1TapCount, 1);
      expect(face2TapCount, 1);
    });

    testWidgets('handles empty faces list gracefully', (tester) async {
      final imageData = InteractiveImageData(
        uri: Uri.parse('asset:test_assets/test_image.png'),
        width: 800,
        height: 600,
        faces: [],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: InteractiveImageViewer(imageData: imageData)),
        ),
      );

      // Should render without error
      expect(find.byType(InteractiveImageViewer), findsOneWidget);

      // Keyboard shortcut should be ignored
      await tester.sendKeyEvent(LogicalKeyboardKey.digit1);
      // No error should occur
    });

    testWidgets('respects showFaceNumbers setting', (tester) async {
      final imageData = InteractiveImageData(
        uri: Uri.parse('asset:test_assets/test_image.png'),
        width: 800,
        height: 600,
        faces: [
          InteractiveFace(
            data: FaceData(
              id: 1,
              bbox: (x1: 0.1, y1: 0.1, x2: 0.3, y2: 0.3),
              confidence: 0.9,
            ),
          ),
        ],
      );

      // With face numbers enabled (default)
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InteractiveImageViewer(
              imageData: imageData,
              showFaceNumbers: true,
            ),
          ),
        ),
      );

      expect(find.text('1'), findsOneWidget);

      // With face numbers disabled
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InteractiveImageViewer(
              imageData: imageData,
              showFaceNumbers: false,
            ),
          ),
        ),
      );

      expect(find.text('1'), findsNothing);
    });
  });

  group('FaceLandmarksPainter', () {
    test('should repaint when landmarks change', () {
      const landmarks1 = FaceLandmarksData(
        leftEye: (x: 0.3, y: 0.3),
        rightEye: (x: 0.7, y: 0.3),
        noseTip: (x: 0.5, y: 0.5),
        mouthLeft: (x: 0.35, y: 0.7),
        mouthRight: (x: 0.65, y: 0.7),
      );

      const landmarks2 = FaceLandmarksData(
        leftEye: (x: 0.35, y: 0.35),
        rightEye: (x: 0.75, y: 0.35),
        noseTip: (x: 0.55, y: 0.55),
        mouthLeft: (x: 0.4, y: 0.75),
        mouthRight: (x: 0.7, y: 0.75),
      );

      final painter1 = FaceLandmarksPainter(
        landmarks: landmarks1,
        faceBox: (x1: 0.2, y1: 0.2, x2: 0.8, y2: 0.8),
      );

      final painter2 = FaceLandmarksPainter(
        landmarks: landmarks2,
        faceBox: (x1: 0.2, y1: 0.2, x2: 0.8, y2: 0.8),
      );

      expect(painter1.shouldRepaint(painter2), isTrue);
    });

    test('should not repaint when landmarks are same', () {
      const landmarks = FaceLandmarksData(
        leftEye: (x: 0.3, y: 0.3),
        rightEye: (x: 0.7, y: 0.3),
        noseTip: (x: 0.5, y: 0.5),
        mouthLeft: (x: 0.35, y: 0.7),
        mouthRight: (x: 0.65, y: 0.7),
      );

      final painter1 = FaceLandmarksPainter(
        landmarks: landmarks,
        faceBox: (x1: 0.2, y1: 0.2, x2: 0.8, y2: 0.8),
      );

      final painter2 = FaceLandmarksPainter(
        landmarks: landmarks,
        faceBox: (x1: 0.2, y1: 0.2, x2: 0.8, y2: 0.8),
      );

      expect(painter1.shouldRepaint(painter2), isFalse);
    });
  });
}
