/// A standalone, self-contained interactive image viewer with face overlay support.
///
/// This package provides widgets for displaying images with interactive face
/// bounding boxes that track with zoom/pan transformations.
///
/// ## Usage
///
/// ```dart
/// import 'package:cl_media_viewer/cl_media_viewer.dart';
///
/// InteractiveImageViewer(
///   imageData: InteractiveImageData(
///     uri: Uri.parse('https://example.com/image.jpg'),
///     width: 1920,
///     height: 1080,
///     faces: [
///       InteractiveFace(
///         data: faceData,
///         onTap: () => print('Face tapped'),
///         onLongPress: () => print('Face long-pressed'),
///       ),
///     ],
///   ),
///   onTap: () => print('Image tapped'),
/// )
/// ```
library cl_media_viewer;

// Models
export 'src/models/interactive_face.dart'
    show InteractiveFace, InteractiveImageData, GesturePositionCallback;

// Widgets
export 'src/widgets/interactive_image_viewer.dart' show InteractiveImageViewer;
export 'src/widgets/interactive_face_box.dart' show InteractiveFaceBox;
export 'src/widgets/face_landmarks_painter.dart' show FaceLandmarksPainter;
