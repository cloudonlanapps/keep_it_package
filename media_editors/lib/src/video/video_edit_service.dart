import 'dart:io';

import '../utils/icons.dart';

import 'package:flutter/material.dart';

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
    return TextButton(
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
                  throw UnimplementedError('ffmpeg removed from project');
                  /* final videoWithoutAudio = await widget.onCreateNewFile();
                  await File(videoWithoutAudio).deleteIfExists();
                  final session = await FFmpegKit.execute(
                    '-i ${widget.inFile} '
                    '-vcodec copy -an '
                    '-f mp4 $videoWithoutAudio',
                  );
                  final returnCode = await session.getReturnCode();
                  if (ReturnCode.isSuccess(returnCode)) {
                    widget.onDone(videoWithoutAudio);
                  } */
                  /* {
                        final output = await session.getOutput();
                        print(output);
                        final logs = await session.getLogs();
                        for (final log in logs) {
                          print(log.getMessage());
                        }
        
                      } */
                }

                if (mounted) {
                  setState(() {
                    isMuting = false;
                  });
                }
              }
            },
      child: isMuting
          ? const CircularProgressIndicator()
          : widget.isMuted
          ? const Icon(
              EditorIcons.audioMuted,
              size: 60,
              color: Colors.white,
            )
          : const Icon(
              EditorIcons.audioUnmuted,
              size: 60,
              color: Colors.white,
            ),
    );
  }
}

/*
() async {
        if (useVideoWithoutAudio) {
          if (audioRemovedFile == null) {
            final videoWithoutAudio = await TheStore.of(context)
                .createTempFile(ext: extension(widget.file.path));
            final session = await FFmpegKit.execute(
              '-i ${widget.file.path} -vcodec copy -an $videoWithoutAudio',
            );
            final returnCode = await session.getReturnCode();
            if (ReturnCode.isSuccess(returnCode)) {
              useVideoWithoutAudio = true;
            }
          }
        } else {
          useVideoWithoutAudio = false;
        }
      }*/
