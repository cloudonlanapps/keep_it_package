import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:media_editors/media_editors.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:share_plus/share_plus.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ShadApp(
      title: 'Media Editor Example',
      darkTheme: ShadThemeData(
        brightness: Brightness.dark,
        colorScheme: const ShadZincColorScheme.dark(),
      ),
      themeMode: ThemeMode.dark,
      builder: (context, child) => ScaffoldMessenger(child: child!),
      home: const Dashboard(),
    );
  }
}

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  Uri? _currentMediaUri;
  bool _isVideo = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Media Editor Example')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_currentMediaUri != null) ...[
              Text('Last edited: ${p.basename(_currentMediaUri!.path)}'),
              const SizedBox(height: 10),
              ShadButton(
                onPressed: () =>
                    _openEditor(_currentMediaUri!, isVideo: _isVideo),
                child: const Text('Edit Last Saved Media'),
              ),
              const SizedBox(height: 40),
            ],
            ShadButton.outline(
              onPressed: () => _pickMedia(FileType.image),
              child: const Text('Pick Image'),
            ),
            const SizedBox(height: 10),
            ShadButton.outline(
              onPressed: () => _pickMedia(FileType.video),
              child: const Text('Pick Video'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickMedia(FileType type) async {
    final result = await FilePicker.platform.pickFiles(type: type);
    if (result != null && result.files.single.path != null) {
      final uri = Uri.file(result.files.single.path!);
      await _openEditor(uri, isVideo: type == FileType.video);
    }
  }

  Future<void> _openEditor(Uri uri, {required bool isVideo}) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => EditorHost(
          initialUri: uri,
          isVideo: isVideo,
          onFinalSave: (newUri) {
            setState(() {
              _currentMediaUri = newUri;
              _isVideo = isVideo;
            });
          },
        ),
      ),
    );
  }
}

class EditorHost extends StatefulWidget {
  const EditorHost({
    required this.initialUri,
    required this.onFinalSave,
    required this.isVideo,
    super.key,
  });

  final Uri initialUri;
  final bool isVideo;
  final void Function(Uri) onFinalSave;

  @override
  State<EditorHost> createState() => _EditorHostState();
}

class _EditorHostState extends State<EditorHost> {
  late Uri _workingUri;
  int _reloadCounter = 0;

  @override
  void initState() {
    super.initState();
    _workingUri = widget.initialUri;
  }

  Future<String> _handleCreateNewFile() async {
    final tempDir = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final extension = p.extension(_workingUri.toFilePath());
    final fileName = 'edited_media_$timestamp$extension';
    return p.join(tempDir.path, fileName);
  }

  Future<void> _handleSave(String tempPath, {required bool overwrite}) async {
    final tempUri = Uri.file(tempPath);

    if (overwrite) {
      if (!mounted) return;
      setState(() {
        _workingUri = tempUri;
        _reloadCounter++;
      });
      widget.onFinalSave(tempUri);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Changes applied. Editor reloaded.')),
      );
    } else {
      await Share.shareXFiles(
        [XFile(tempPath)],
        text: 'Check out my edited media!',
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Copy shared successfully.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.isVideo ? 'Editing Video' : 'Editing Image'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: widget.isVideo
          ? VideoEditor(
              key: ValueKey('editor_$_workingUri$_reloadCounter'),
              uri: _workingUri,
              canDuplicateMedia: true,
              onCreateNewFile: _handleCreateNewFile,
              onSave: _handleSave,
              onCancel: () async {
                Navigator.of(context).pop();
              },
            )
          : ImageEditor(
              key: ValueKey('editor_$_workingUri$_reloadCounter'),
              uri: _workingUri,
              canDuplicateMedia: true,
              onCreateNewFile: _handleCreateNewFile,
              onSave: _handleSave,
              onCancel: () async {
                Navigator.of(context).pop();
              },
            ),
    );
  }
}
