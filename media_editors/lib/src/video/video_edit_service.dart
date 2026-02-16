import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../utils/ffmpeg.dart';
import '../utils/icons.dart';
import 'widgets/video_trimmer.dart';

class VideoEditor extends StatefulWidget {
  const VideoEditor({
    required this.uri,
    required this.onSave,
    required this.onCancel,
    required this.onCreateNewFile,
    required this.canDuplicateMedia,
    super.key,
  });
  final Uri uri;
  final Future<void> Function(String outFile, {required bool overwrite}) onSave;
  final Future<void> Function() onCancel;
  final bool canDuplicateMedia;
  final Future<String> Function() onCreateNewFile;

  @override
  State<VideoEditor> createState() => _VideoEditorState();
}

class _VideoEditorState extends State<VideoEditor> {
  String? audioRemovedFile;
  GlobalKey key = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final currFile = audioRemovedFile ?? widget.uri.toFilePath();

    return VideoTrimmerView(
      File(currFile),
      key: key,
      onSave: widget.onSave,
      onCancel: widget.onCancel,
      canDuplicateMedia: widget.canDuplicateMedia,
      isMuted: audioRemovedFile != null,
      onReset: () {
        setState(() {
          audioRemovedFile = null;
          key = GlobalKey();
        });
      },
      audioMuter: AudioMuter(
        widget.uri.toFilePath(),
        onCreateNewFile: widget.onCreateNewFile,
        onDone: (file) {
          setState(() {
            audioRemovedFile = file;
            key = GlobalKey();
          });
        },
        isMuted: audioRemovedFile != null,
      ),
    );
  }
}

class AudioMuter extends StatefulWidget {
  const AudioMuter(
    this.inFile, {
    required this.onDone,
    required this.isMuted,
    required this.onCreateNewFile,
    super.key,
  });
  final void Function(String? filePath) onDone;
  final Future<String> Function() onCreateNewFile;
  final bool isMuted;
  final String inFile;
  @override
  State<AudioMuter> createState() => _AudioMuterState();
}

class _AudioMuterState extends State<AudioMuter> {
  bool isMuting = false;
  String? outFile;

  @override
  Widget build(BuildContext context) {
    if (isMuting) {}
    return ShadButton.ghost(
      onPressed: isMuting
          ? null
          : () async {
              if (widget.isMuted) {
                // Unmute by sending null
                widget.onDone(null);
              } else {
                setState(() {
                  isMuting = true;
                });

                if (outFile == null) {
                  if (!Platform.isMacOS) {
                    if (mounted) {
                      ShadToaster.of(context).show(
                        const ShadToast(
                          description: Text(
                            'Muting is currently only supported on macOS.',
                          ),
                        ),
                      );
                    }
                    setState(() {
                      isMuting = false;
                    });
                    return;
                  }

                  final newFile = await widget.onCreateNewFile();
                  final success = await NativeFFmpeg.muteVideo(
                    inputPath: widget.inFile,
                    outputPath: newFile,
                  );

                  if (success) {
                    outFile = newFile;
                    widget.onDone(newFile);
                  } else {
                    if (context.mounted) {
                      ShadToaster.of(context).show(
                        const ShadToast(
                          description: Text(
                            'Failed to mute video. Ensure FFmpeg is installed.',
                          ),
                        ),
                      );
                    }
                  }
                } else {
                  widget.onDone(outFile);
                }

                if (mounted) {
                  setState(() {
                    isMuting = false;
                  });
                }
              }
            },
      child: isMuting
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(
              widget.isMuted
                  ? EditorIcons.audioMuted
                  : EditorIcons.audioUnmuted,
              size: 24,
              color: Colors.white,
            ),
    );
  }
}
