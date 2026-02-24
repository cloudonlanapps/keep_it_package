import 'package:cl_media_viewer/cl_media_viewer.dart';
import 'package:flutter/material.dart';

/// Screen showing a list of available videos to play.
class VideoListScreen extends StatefulWidget {
  const VideoListScreen({super.key});

  @override
  State<VideoListScreen> createState() => _VideoListScreenState();
}

class _VideoListScreenState extends State<VideoListScreen> {
  final TextEditingController _urlController = TextEditingController();
  final FocusNode _urlFocusNode = FocusNode();
  String? _urlError;

  // List of available video assets
  final List<VideoInfo> _videos = [
    const VideoInfo(
      name: 'Sample Video',
      uri: 'asset:assets/videos/18.mp4',
      isStream: false,
    ),
  ];

  @override
  void dispose() {
    _urlController.dispose();
    _urlFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Examples'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _videos.length + 1, // +1 for the URL input row
        itemBuilder: (context, index) {
          // Last item is the URL input row
          if (index == _videos.length) {
            return _buildUrlInputRow(context);
          }

          final video = _videos[index];
          return _buildVideoRow(context, video, index);
        },
      ),
    );
  }

  Widget _buildVideoRow(BuildContext context, VideoInfo video, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _openVideoPlayer(context, video),
        onLongPress: video.isStream ? () => _showDeleteDialog(context, index) : null,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 80,
                height: 60,
                decoration: BoxDecoration(
                  color: video.isStream ? Colors.purple[100] : Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  video.isStream ? Icons.stream : Icons.play_circle_outline,
                  size: 40,
                  color: video.isStream ? Colors.purple : Colors.grey,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            video.name,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        if (video.isStream)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.purple,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'STREAM',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      video.uri,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: Colors.grey[600]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
  }

  Widget _buildUrlInputRow(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 80,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.add_link,
                    size: 32,
                    color: Colors.blue[400],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _urlController,
                    focusNode: _urlFocusNode,
                    decoration: InputDecoration(
                      hintText: 'Enter video or stream URL...',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                      errorText: _urlError,
                      errorStyle: const TextStyle(fontSize: 11),
                    ),
                    style: Theme.of(context).textTheme.bodyMedium,
                    keyboardType: TextInputType.url,
                    textInputAction: TextInputAction.go,
                    onSubmitted: (_) => _playUrl(),
                    onChanged: (_) {
                      if (_urlError != null) {
                        setState(() => _urlError = null);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _playUrl,
                  icon: const Icon(Icons.chevron_right),
                  tooltip: 'Play',
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 96, top: 4),
              child: Text(
                'Supports HLS (.m3u8), MP4, and other video URLs',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Colors.grey[500], fontSize: 11),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _playUrl() {
    final url = _urlController.text.trim();

    if (url.isEmpty) {
      setState(() => _urlError = 'Please enter a URL');
      return;
    }

    // Validate URL
    final uri = Uri.tryParse(url);
    if (uri == null || !uri.hasScheme || !['http', 'https'].contains(uri.scheme)) {
      setState(() => _urlError = 'Please enter a valid http/https URL');
      return;
    }

    // Clear error and play
    setState(() => _urlError = null);

    final video = VideoInfo(
      name: _extractName(uri),
      uri: url,
      isStream: true,
    );

    _openVideoPlayer(context, video);
  }

  String _extractName(Uri uri) {
    // Try to extract a meaningful name from the URL
    final pathSegments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
    if (pathSegments.isNotEmpty) {
      final lastSegment = pathSegments.last;
      // Remove extension if present
      final nameWithoutExt = lastSegment.replaceAll(RegExp(r'\.[^.]+$'), '');
      if (nameWithoutExt.isNotEmpty && nameWithoutExt.length > 2) {
        return nameWithoutExt;
      }
    }
    return uri.host;
  }

  void _openVideoPlayer(BuildContext context, VideoInfo video) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => VideoPlayerScreen(video: video),
      ),
    );
  }

  Future<void> _showDeleteDialog(BuildContext context, int index) async {
    final video = _videos[index];
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Stream'),
        content: Text('Remove "${video.name}" from the list?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (result == true) {
      setState(() {
        _videos.removeAt(index);
      });
    }
  }
}

/// Data model for video information.
class VideoInfo {
  const VideoInfo({
    required this.name,
    required this.uri,
    this.isStream = false,
  });

  final String name;
  final String uri;
  final bool isStream;
}

/// Screen showing the interactive video player.
class VideoPlayerScreen extends StatefulWidget {
  const VideoPlayerScreen({
    required this.video,
    super.key,
  });

  final VideoInfo video;

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late final DefaultVideoViewerController _controller;
  bool _isInitialized = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller = DefaultVideoViewerController();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      final uri = Uri.parse(widget.video.uri);
      await _controller.initialize(uri);
      await _controller.play();
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
        });
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.video.name),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          if (widget.video.isStream)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.purple,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.stream, size: 16, color: Colors.white),
                  SizedBox(width: 4),
                  Text(
                    'LIVE',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      body: _buildBody(),
      backgroundColor: Colors.black,
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
            const Text(
              'Error loading video',
              style: TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                _error!,
                style: const TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'URL: ${widget.video.uri}',
                style: const TextStyle(color: Colors.grey, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white54),
                  ),
                  child: const Text('Close'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _error = null;
                      _isInitialized = false;
                    });
                    _initializeVideo();
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          ],
        ),
      );
    }

    if (!_isInitialized) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              widget.video.isStream ? 'Connecting to stream...' : 'Loading...',
              style: const TextStyle(color: Colors.white70),
            ),
          ],
        ),
      );
    }

    return Center(
      child: InteractiveVideoViewer(
        controller: _controller,
        showControls: true,
        keepAspectRatio: true,
      ),
    );
  }
}
