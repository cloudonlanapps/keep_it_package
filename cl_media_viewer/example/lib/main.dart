import 'dart:convert';

import 'package:cl_basic_types/cl_basic_types.dart';
import 'package:cl_media_viewer/cl_media_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'video_example.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Media Viewer Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

/// Home screen with bottom navigation for Images and Videos.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _pages = [
    ImageListScreen(),
    VideoListScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.image_outlined),
            selectedIcon: Icon(Icons.image),
            label: 'Images',
          ),
          NavigationDestination(
            icon: Icon(Icons.video_library_outlined),
            selectedIcon: Icon(Icons.video_library),
            label: 'Videos',
          ),
        ],
      ),
    );
  }
}

/// Data model for an image with its face data.
class ImageWithFaces {
  const ImageWithFaces({
    required this.name,
    required this.assetPath,
    required this.width,
    required this.height,
    required this.faces,
  });

  final String name;
  final String assetPath;
  final int width;
  final int height;
  final List<FaceData> faces;

  /// Load from JSON asset.
  static Future<ImageWithFaces> fromAsset(String imageName) async {
    final jsonPath = 'assets/faces/$imageName.json';
    final jsonString = await rootBundle.loadString(jsonPath);
    final json = jsonDecode(jsonString) as Map<String, dynamic>;

    final faces = (json['faces'] as List<dynamic>)
        .map((f) => _parseFaceData(f as Map<String, dynamic>))
        .toList();

    return ImageWithFaces(
      name: json['name'] as String,
      assetPath: 'assets/images/$imageName',
      width: json['width'] as int,
      height: json['height'] as int,
      faces: faces,
    );
  }

  static FaceData _parseFaceData(Map<String, dynamic> json) {
    final bbox = json['bbox'] as Map<String, dynamic>;
    final landmarksJson = json['landmarks'] as Map<String, dynamic>?;

    FaceLandmarksData? landmarks;
    if (landmarksJson != null) {
      landmarks = FaceLandmarksData(
        leftEye: (
          x: (landmarksJson['leftEye'] as List)[0] as double,
          y: (landmarksJson['leftEye'] as List)[1] as double,
        ),
        rightEye: (
          x: (landmarksJson['rightEye'] as List)[0] as double,
          y: (landmarksJson['rightEye'] as List)[1] as double,
        ),
        noseTip: (
          x: (landmarksJson['noseTip'] as List)[0] as double,
          y: (landmarksJson['noseTip'] as List)[1] as double,
        ),
        mouthLeft: (
          x: (landmarksJson['mouthLeft'] as List)[0] as double,
          y: (landmarksJson['mouthLeft'] as List)[1] as double,
        ),
        mouthRight: (
          x: (landmarksJson['mouthRight'] as List)[0] as double,
          y: (landmarksJson['mouthRight'] as List)[1] as double,
        ),
      );
    }

    return FaceData(
      id: json['id'] as int,
      bbox: (
        x1: (bbox['x1'] as num).toDouble(),
        y1: (bbox['y1'] as num).toDouble(),
        x2: (bbox['x2'] as num).toDouble(),
        y2: (bbox['y2'] as num).toDouble(),
      ),
      confidence: (json['confidence'] as num).toDouble(),
      landmarks: landmarks,
      knownPersonId: json['knownPersonId'] as int?,
    );
  }
}

/// Screen showing a list of available images.
class ImageListScreen extends StatelessWidget {
  const ImageListScreen({super.key});

  // List of available image names
  static const List<String> _imageNames = [
    '2.jpg',
    '3.jpg',
    '4.jpg',
    '5.jpg',
    '6.jpg',
    '7.jpg',
    '8.jpg',
    '9.jpg',
    '10.jpg',
    '11.jpg',
    '12.jpg',
    '13.png',
    '14.png',
    '15.png',
    '16.png',
    '17.png',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Examples'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _imageNames.length,
        itemBuilder: (context, index) {
          final imageName = _imageNames[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => _openImageViewer(context, imageName),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    // Thumbnail preview
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: SizedBox(
                        width: 80,
                        height: 60,
                        child: Image.asset(
                          'assets/images/$imageName',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stack) => Container(
                            color: Colors.grey[300],
                            child: const Icon(
                              Icons.image_not_supported,
                              size: 32,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            imageName,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'assets/images/$imageName',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.grey[600],
                                ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _openImageViewer(BuildContext context, String imageName) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => ImageViewerScreen(imageName: imageName),
      ),
    );
  }
}

/// Screen showing the interactive image viewer.
class ImageViewerScreen extends StatefulWidget {
  const ImageViewerScreen({
    required this.imageName,
    super.key,
  });

  final String imageName;

  @override
  State<ImageViewerScreen> createState() => _ImageViewerScreenState();
}

class _ImageViewerScreenState extends State<ImageViewerScreen> {
  ImageWithFaces? _imageData;
  String? _error;
  int? _selectedFaceId;

  @override
  void initState() {
    super.initState();
    _loadImageData();
  }

  Future<void> _loadImageData() async {
    try {
      final data = await ImageWithFaces.fromAsset(widget.imageName);
      setState(() {
        _imageData = data;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.imageName),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          if (_imageData != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: Text(
                  '${_imageData!.faces.length} faces',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text('Error loading image data'),
            const SizedBox(height: 8),
            Text(_error!, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _error = null;
                });
                _loadImageData();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_imageData == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    final imageData = _imageData!;

    return InteractiveImageViewer(
      imageData: InteractiveImageData(
        uri: Uri.parse('asset:${imageData.assetPath}'),
        width: imageData.width,
        height: imageData.height,
        faces: imageData.faces.map((faceData) {
          return InteractiveFace(
            data: faceData,
            onTap: (position) => _onFaceTap(faceData, position),
            onLongPress: (position) => _onFaceLongPress(faceData, position),
            onSecondaryTap: (position) =>
                _showFaceContextMenu(faceData, position),
            showLandmarks: _selectedFaceId == faceData.id,
          );
        }).toList(),
      ),
      selectedFaceId: _selectedFaceId,
      onTap: () {
        // Deselect when tapping outside faces
        setState(() {
          _selectedFaceId = null;
        });
      },
    );
  }

  void _onFaceTap(FaceData face, Offset position) {
    setState(() {
      _selectedFaceId = face.id;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Face #${face.id} tapped at (${position.dx.toInt()}, ${position.dy.toInt()})\n'
          'Confidence: ${(face.confidence * 100).toStringAsFixed(1)}%',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _onFaceLongPress(FaceData face, Offset position) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Face #${face.id}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Confidence: ${(face.confidence * 100).toStringAsFixed(1)}%'),
            Text(
                'Bounding box: (${face.bbox.x1.toStringAsFixed(3)}, ${face.bbox.y1.toStringAsFixed(3)}) - '
                '(${face.bbox.x2.toStringAsFixed(3)}, ${face.bbox.y2.toStringAsFixed(3)})'),
            Text('Width: ${(face.width * 100).toStringAsFixed(1)}%'),
            Text('Height: ${(face.height * 100).toStringAsFixed(1)}%'),
            if (face.landmarks != null) ...[
              const SizedBox(height: 8),
              const Text('Landmarks:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Text(
                  'Left eye: (${face.landmarks!.leftEye.x.toStringAsFixed(3)}, ${face.landmarks!.leftEye.y.toStringAsFixed(3)})'),
              Text(
                  'Right eye: (${face.landmarks!.rightEye.x.toStringAsFixed(3)}, ${face.landmarks!.rightEye.y.toStringAsFixed(3)})'),
              Text(
                  'Nose: (${face.landmarks!.noseTip.x.toStringAsFixed(3)}, ${face.landmarks!.noseTip.y.toStringAsFixed(3)})'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showFaceContextMenu(FaceData face, Offset position) {
    showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        position.dx,
        position.dy,
      ),
      items: [
        const PopupMenuItem(
          value: 'select',
          child: Text('Select face'),
        ),
        const PopupMenuItem(
          value: 'details',
          child: Text('View details'),
        ),
        PopupMenuItem(
          value: 'landmarks',
          child: Text(_selectedFaceId == face.id
              ? 'Hide landmarks'
              : 'Show landmarks'),
        ),
      ],
    ).then((value) {
      if (value == null) return;

      switch (value) {
        case 'select':
          setState(() {
            _selectedFaceId = face.id;
          });
        case 'details':
          _onFaceLongPress(face, position);
        case 'landmarks':
          setState(() {
            if (_selectedFaceId == face.id) {
              _selectedFaceId = null;
            } else {
              _selectedFaceId = face.id;
            }
          });
      }
    });
  }
}
