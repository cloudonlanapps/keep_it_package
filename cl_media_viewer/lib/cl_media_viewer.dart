/// A standalone, self-contained interactive image viewer with face overlay support.
///
/// This package provides a widget for displaying images with interactive face
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
///         onTap: (position) => print('Face tapped at $position'),
///         onLongPress: (position) => print('Face long-pressed'),
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
