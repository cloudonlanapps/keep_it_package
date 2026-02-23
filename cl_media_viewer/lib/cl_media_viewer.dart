/// A standalone, self-contained media viewer package with interactive overlays.
///
/// This package provides widgets for displaying images and videos with interactive
/// features like face bounding boxes (for images) and playback controls (for videos).
///
/// ## Image Viewer
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
///
/// ## Video Viewer
///
/// ```dart
/// import 'package:cl_media_viewer/cl_media_viewer.dart';
///
/// final controller = DefaultVideoViewerController();
/// await controller.initialize(Uri.parse('asset:assets/video.mp4'));
///
/// InteractiveVideoViewer(
///   controller: controller,
///   showControls: true,
///   onTap: () => print('Video tapped'),
/// )
/// ```
library;

// Image viewer - models
export 'src/image/models/interactive_face.dart'
    show InteractiveFace, InteractiveImageData, GesturePositionCallback;

// Image viewer - widgets
export 'src/image/widgets/interactive_image_viewer.dart'
    show InteractiveImageViewer;

// Video viewer - models
export 'src/video/models/video_viewer_controller.dart'
    show VideoViewerController, DefaultVideoViewerController;

// Video viewer - widgets
export 'src/video/widgets/interactive_video_viewer.dart'
    show InteractiveVideoViewer;
