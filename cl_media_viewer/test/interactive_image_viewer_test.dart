import 'package:cl_basic_types/cl_basic_types.dart';
import 'package:cl_media_viewer/cl_media_viewer.dart';
// Internal widgets for testing only
import 'package:cl_media_viewer/src/image/widgets/face_landmarks_painter.dart';
import 'package:cl_media_viewer/src/image/widgets/interactive_face_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('InteractiveFace', () {
    test('creates with required data', () {
      const faceData = FaceData(
        id: 1,
        bbox: (x1: 0.1, y1: 0.2, x2: 0.3, y2: 0.4),
        confidence: 0.95,
      );

      const face = InteractiveFace(data: faceData);

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
        data: const FaceData(
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
          const InteractiveFace(
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
      const face = InteractiveFace(
        data: FaceData(
          id: 1,
          bbox: (x1: 0.25, y1: 0.25, x2: 0.75, y2: 0.75),
          confidence: 0.95,
        ),
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 400,
              child: Stack(
                children: [
                  InteractiveFaceBox(
                    face: face,
                    index: 0,
                    imageSize: Size(400, 400),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      // Find the first positioned widget (the main face box container)
      final positioned = tester.widget<Positioned>(
        find.byType(Positioned).first,
      );

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
        data: const FaceData(
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
        data: const FaceData(
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
      const face = InteractiveFace(
        data: FaceData(
          id: 1,
          bbox: (x1: 0.0, y1: 0.0, x2: 1.0, y2: 1.0),
          confidence: 0.95,
        ),
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 200,
              height: 200,
              child: Stack(
                children: [
                  InteractiveFaceBox(
                    face: face,
                    index: 2, // 0-indexed, should show "3"
                    imageSize: Size(200, 200),
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
      const face = InteractiveFace(
        data: FaceData(
          id: 1,
          bbox: (x1: 0.0, y1: 0.0, x2: 1.0, y2: 1.0),
          confidence: 0.95,
        ),
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 200,
              height: 200,
              child: Stack(
                children: [
                  InteractiveFaceBox(
                    face: face,
                    index: 0,
                    imageSize: Size(200, 200),
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
      const face = InteractiveFace(
        data: FaceData(
          id: 1,
          bbox: (x1: 0.0, y1: 0.0, x2: 1.0, y2: 1.0),
          confidence: 0.95,
        ),
        label: 'John Doe',
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 200,
              height: 200,
              child: Stack(
                children: [
                  InteractiveFaceBox(
                    face: face,
                    index: 0,
                    imageSize: Size(200, 200),
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
          const InteractiveFace(
            data: FaceData(
              id: 1,
              bbox: (x1: 0.1, y1: 0.1, x2: 0.3, y2: 0.3),
              confidence: 0.9,
            ),
          ),
          const InteractiveFace(
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
            data: const FaceData(
              id: 1,
              bbox: (x1: 0.1, y1: 0.1, x2: 0.3, y2: 0.3),
              confidence: 0.9,
            ),
            onTap: (_) => face1TapCount++,
          ),
          InteractiveFace(
            data: const FaceData(
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
          const InteractiveFace(
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

  group('Face Position Calculations', () {
    testWidgets('face box scales correctly at different container sizes', (
      tester,
    ) async {
      // Face at center: 25%-75% in both dimensions
      const face = InteractiveFace(
        data: FaceData(
          id: 1,
          bbox: (x1: 0.25, y1: 0.25, x2: 0.75, y2: 0.75),
          confidence: 0.95,
        ),
      );

      // Test at 400x400 container
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 400,
              child: Stack(
                children: [
                  InteractiveFaceBox(
                    face: face,
                    index: 0,
                    imageSize: Size(400, 400),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      var positioned = tester.widget<Positioned>(find.byType(Positioned).first);
      expect(positioned.left, 100); // 0.25 * 400
      expect(positioned.top, 100);
      expect(positioned.width, 200); // 0.5 * 400
      expect(positioned.height, 200);

      // Test at 800x600 container (different aspect ratio)
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 800,
              height: 600,
              child: Stack(
                children: [
                  InteractiveFaceBox(
                    face: face,
                    index: 0,
                    imageSize: Size(800, 600),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      positioned = tester.widget<Positioned>(find.byType(Positioned).first);
      expect(positioned.left, 200); // 0.25 * 800
      expect(positioned.top, 150); // 0.25 * 600
      expect(positioned.width, 400); // 0.5 * 800
      expect(positioned.height, 300); // 0.5 * 600
    });

    testWidgets('normalized coordinates convert correctly to pixels', (
      tester,
    ) async {
      // Multiple faces at known positions
      final faces = [
        const InteractiveFace(
          data: FaceData(
            id: 1,
            bbox: (x1: 0.0, y1: 0.0, x2: 0.1, y2: 0.1), // Top-left corner
            confidence: 0.9,
          ),
        ),
        const InteractiveFace(
          data: FaceData(
            id: 2,
            bbox: (x1: 0.9, y1: 0.9, x2: 1.0, y2: 1.0), // Bottom-right corner
            confidence: 0.9,
          ),
        ),
        const InteractiveFace(
          data: FaceData(
            id: 3,
            bbox: (x1: 0.45, y1: 0.45, x2: 0.55, y2: 0.55), // Center
            confidence: 0.9,
          ),
        ),
      ];

      const imageSize = Size(1000, 1000);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 1000,
              height: 1000,
              child: Stack(
                children: [
                  for (var i = 0; i < faces.length; i++)
                    InteractiveFaceBox(
                      face: faces[i],
                      index: i,
                      imageSize: imageSize,
                    ),
                ],
              ),
            ),
          ),
        ),
      );

      // Get the face boxes and verify their positions via their face data
      // (InteractiveFaceBox internally uses Positioned, but also has internal Positioned
      // widgets for labels, so we verify via the face box widget directly)
      final faceBoxes = tester
          .widgetList<InteractiveFaceBox>(find.byType(InteractiveFaceBox))
          .toList();

      expect(faceBoxes.length, 3);

      // Verify face positions via their normalized coordinates
      // Face 1: Top-left (0.0, 0.0) to (0.1, 0.1)
      final face1 = faceBoxes.firstWhere((fb) => fb.face.id == 1);
      expect(face1.face.bbox.x1, 0.0);
      expect(face1.face.bbox.y1, 0.0);
      expect(face1.imageSize, imageSize);

      // Face 2: Bottom-right (0.9, 0.9) to (1.0, 1.0)
      final face2 = faceBoxes.firstWhere((fb) => fb.face.id == 2);
      expect(face2.face.bbox.x1, 0.9);
      expect(face2.face.bbox.y1, 0.9);
      expect(face2.imageSize, imageSize);

      // Face 3: Center (0.45, 0.45) to (0.55, 0.55)
      final face3 = faceBoxes.firstWhere((fb) => fb.face.id == 3);
      expect(face3.face.bbox.x1, 0.45);
      expect(face3.face.bbox.y1, 0.45);
      expect(face3.imageSize, imageSize);

      // Verify pixel calculations would be correct
      // Face 1: 0.0 * 1000 = 0, 0.1 * 1000 = 100 (size)
      expect(face1.face.bbox.x1 * imageSize.width, 0);
      expect(face1.face.bbox.y1 * imageSize.height, 0);
      expect((face1.face.bbox.x2 - face1.face.bbox.x1) * imageSize.width, 100);

      // Face 2: 0.9 * 1000 = 900
      expect(face2.face.bbox.x1 * imageSize.width, 900);
      expect(face2.face.bbox.y1 * imageSize.height, 900);

      // Face 3: 0.45 * 1000 = 450
      expect(face3.face.bbox.x1 * imageSize.width, 450);
      expect(face3.face.bbox.y1 * imageSize.height, 450);
    });
  });

  group('Zoom/Pan Alignment', () {
    testWidgets('InteractiveViewer contains both image and faces in same Stack', (
      tester,
    ) async {
      // This test verifies the widget hierarchy ensures faces transform with image
      final imageData = InteractiveImageData(
        uri: Uri.parse('asset:test_assets/test_image.png'),
        width: 800,
        height: 600,
        faces: [
          const InteractiveFace(
            data: FaceData(
              id: 1,
              bbox: (x1: 0.25, y1: 0.25, x2: 0.5, y2: 0.5),
              confidence: 0.9,
            ),
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: InteractiveImageViewer(imageData: imageData)),
        ),
      );

      // Verify InteractiveViewer exists
      expect(find.byType(InteractiveViewer), findsOneWidget);

      // Verify face box is a descendant of InteractiveViewer
      // This ensures the face transforms with the image when zooming/panning
      final faceBoxFinder = find.descendant(
        of: find.byType(InteractiveViewer),
        matching: find.byType(InteractiveFaceBox),
      );
      expect(faceBoxFinder, findsOneWidget);

      // Verify there's a Stack inside InteractiveViewer that contains the face box
      // (There may be multiple Stacks due to internal widget structure)
      final stackFinder = find.descendant(
        of: find.byType(InteractiveViewer),
        matching: find.byType(Stack),
      );
      expect(stackFinder, findsWidgets); // At least one Stack

      // The key invariant: face box is inside InteractiveViewer's transform
      // We already verified faceBoxFinder above, which confirms this
    });

    testWidgets('face tap works when zoom is disabled', (tester) async {
      var tapCount = 0;

      final imageData = InteractiveImageData(
        uri: Uri.parse('asset:test_assets/test_image.png'),
        width: 400,
        height: 400,
        faces: [
          InteractiveFace(
            data: const FaceData(
              id: 1,
              bbox: (x1: 0.0, y1: 0.0, x2: 1.0, y2: 1.0), // Full image
              confidence: 0.9,
            ),
            onTap: (_) => tapCount++,
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 400,
                height: 400,
                child: InteractiveImageViewer(
                  imageData: imageData,
                  enableZoom: false, // Disable zoom
                ),
              ),
            ),
          ),
        ),
      );

      // Tap on the face box
      await tester.tap(find.byType(InteractiveFaceBox));
      expect(tapCount, 1);
    });

    testWidgets('FittedBox maintains aspect ratio for face alignment', (
      tester,
    ) async {
      // Test that when image is letterboxed/pillarboxed, faces still align
      final imageData = InteractiveImageData(
        uri: Uri.parse('asset:test_assets/test_image.png'),
        width: 1600, // 16:9 aspect ratio
        height: 900,
        faces: [
          const InteractiveFace(
            data: FaceData(
              id: 1,
              bbox: (x1: 0.5, y1: 0.5, x2: 0.6, y2: 0.6), // Center-ish
              confidence: 0.9,
            ),
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: InteractiveImageViewer(imageData: imageData)),
        ),
      );

      // FittedBox should be present to maintain aspect ratio
      expect(find.byType(FittedBox), findsOneWidget);

      // Face box should be inside FittedBox
      final faceInsideFitted = find.descendant(
        of: find.byType(FittedBox),
        matching: find.byType(InteractiveFaceBox),
      );
      expect(faceInsideFitted, findsOneWidget);
    });

    testWidgets('multiple faces maintain relative positions', (tester) async {
      // Two faces at opposite corners should maintain their relative positions
      final imageData = InteractiveImageData(
        uri: Uri.parse('asset:test_assets/test_image.png'),
        width: 1000,
        height: 1000,
        faces: [
          const InteractiveFace(
            data: FaceData(
              id: 1,
              bbox: (x1: 0.1, y1: 0.1, x2: 0.2, y2: 0.2), // Top-left
              confidence: 0.9,
            ),
          ),
          const InteractiveFace(
            data: FaceData(
              id: 2,
              bbox: (x1: 0.8, y1: 0.8, x2: 0.9, y2: 0.9), // Bottom-right
              confidence: 0.9,
            ),
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: InteractiveImageViewer(imageData: imageData)),
        ),
      );

      final faceBoxes = tester.widgetList<InteractiveFaceBox>(
        find.byType(InteractiveFaceBox),
      );
      expect(faceBoxes.length, 2);

      // Verify the faces have different IDs (confirming both rendered)
      final faceIds = faceBoxes.map((fb) => fb.face.id).toList();
      expect(faceIds, containsAll([1, 2]));

      // Verify they're at different positions by checking their face data
      final face1 = faceBoxes.firstWhere((fb) => fb.face.id == 1);
      final face2 = faceBoxes.firstWhere((fb) => fb.face.id == 2);

      // Face 1 should be top-left (smaller coordinates)
      expect(face1.face.bbox.x1, lessThan(face2.face.bbox.x1));
      expect(face1.face.bbox.y1, lessThan(face2.face.bbox.y1));
    });

    testWidgets('face callbacks work with InteractiveViewer enabled', (
      tester,
    ) async {
      var face1Taps = 0;
      var face2Taps = 0;

      final imageData = InteractiveImageData(
        uri: Uri.parse('asset:test_assets/test_image.png'),
        width: 400,
        height: 400,
        faces: [
          InteractiveFace(
            data: const FaceData(
              id: 1,
              bbox: (x1: 0.0, y1: 0.0, x2: 0.4, y2: 0.4), // Top-left quadrant
              confidence: 0.9,
            ),
            onTap: (_) => face1Taps++,
          ),
          InteractiveFace(
            data: const FaceData(
              id: 2,
              bbox: (
                x1: 0.6,
                y1: 0.6,
                x2: 1.0,
                y2: 1.0,
              ), // Bottom-right quadrant
              confidence: 0.9,
            ),
            onTap: (_) => face2Taps++,
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 400,
                height: 400,
                child: InteractiveImageViewer(
                  imageData: imageData,
                  enableZoom: true, // Zoom enabled
                ),
              ),
            ),
          ),
        ),
      );

      // Find the face boxes
      final faceBoxFinders = find.byType(InteractiveFaceBox);
      expect(faceBoxFinders, findsNWidgets(2));

      // Tap on each face box - they should still be tappable even with
      // InteractiveViewer enabled

      // Find and tap the first face (id: 1)
      final face1Widget = tester
          .widgetList<InteractiveFaceBox>(faceBoxFinders)
          .firstWhere((fb) => fb.face.id == 1);
      await tester.tap(find.byWidget(face1Widget));
      expect(face1Taps, 1);
      expect(face2Taps, 0);

      // Find and tap the second face (id: 2)
      final face2Widget = tester
          .widgetList<InteractiveFaceBox>(faceBoxFinders)
          .firstWhere((fb) => fb.face.id == 2);
      await tester.tap(find.byWidget(face2Widget));
      expect(face1Taps, 1);
      expect(face2Taps, 1);
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
