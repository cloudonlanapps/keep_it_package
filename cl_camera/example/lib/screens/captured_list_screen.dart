import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:share_plus/share_plus.dart';

class CapturedListScreen extends StatefulWidget {
  const CapturedListScreen({required this.paths, super.key});

  final List<String> paths;

  @override
  State<CapturedListScreen> createState() => _CapturedListScreenState();
}

class _CapturedListScreenState extends State<CapturedListScreen> {
  bool _isBusy = false;

  Future<void> _saveToDocuments() async {
    setState(() => _isBusy = true);
    try {
      final docsDir = await getApplicationDocumentsDirectory();
      final saveDir = Directory('${docsDir.path}/cl_camera_captures');
      await saveDir.create(recursive: true);

      for (final path in widget.paths) {
        final fileName = path.split('/').last;
        await File(path).copy('${saveDir.path}/$fileName');
      }

      if (mounted) {
        ShadToaster.of(context).show(
          ShadToast.destructive(
            title: Text(
              'Saved ${widget.paths.length} file(s) to Documents/cl_camera_captures',
            ),
            description: Text(''),
          ),
        );

        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ShadToaster.of(context).show(
          ShadToast.destructive(
            title: Text('Save failed: $e'),
            description: Text(''),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Future<void> _share() async {
    setState(() => _isBusy = true);
    try {
      final xFiles = widget.paths.map(XFile.new).toList();
      await Share.shareXFiles(xFiles);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ShadToaster.of(context).show(
          ShadToast.destructive(
            title: Text('Share failed: $e'),
            description: Text(''),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Review (${widget.paths.length})'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: widget.paths.length,
              separatorBuilder: (context, i) =>
                  const Divider(color: Colors.white12, height: 1),
              itemBuilder: (context, index) {
                final path = widget.paths[index];
                final name = path.split('/').last;
                final isVideo =
                    name.endsWith('.mp4') ||
                    name.endsWith('.mov') ||
                    name.endsWith('.m4v');
                return ListTile(
                  leading: Icon(
                    isVideo ? Icons.videocam : Icons.image,
                    color: Colors.white70,
                  ),
                  title: Text(
                    name,
                    style: const TextStyle(color: Colors.white),
                  ),
                );
              },
            ),
          ),
          const Divider(color: Colors.white24, height: 1),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isBusy ? null : _saveToDocuments,
                    icon: const Icon(Icons.save_alt),
                    label: const Text('Save to Documents'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white38),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _isBusy ? null : _share,
                    icon: const Icon(Icons.share),
                    label: const Text('Share'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
