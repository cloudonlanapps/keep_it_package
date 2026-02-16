import 'dart:io';

class NativeFFmpeg {
  static Future<bool> muteVideo({
    required String inputPath,
    required String outputPath,
  }) async {
    if (!Platform.isMacOS) {
      stderr.writeln(
        'NativeFFmpeg: Muting is currently only supported on macOS.',
      );
      return false;
    }

    try {
      // ffmpeg -i input.mp4 -vcodec copy -an outputPath.mp4
      final result = await Process.run(
        'ffmpeg',
        [
          '-y', // Overwrite output files without asking
          '-i', inputPath,
          '-vcodec', 'copy',
          '-an', // Remove audio
          outputPath,
        ],
      );

      return result.exitCode == 0;
    } catch (e) {
      stderr.writeln('FFmpeg error: $e');
      return false;
    }
  }
}
