import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:background_downloader/background_downloader.dart';
import 'package:path/path.dart' as p;

typedef ProgressCallback = void Function(String filePath, double progress);
typedef StatusCallback = void Function(String filePath, TaskStatus status);
typedef ErrorCallback = void Function(String filePath, String error);
typedef ResetCallback = void Function(String filePath);
typedef CompletedCallback =
    void Function(
      String filePath,
      String identity,
      Map<String, dynamic> responseMap,
    );
typedef LogCallback = void Function(String msg);

// Imports remain the same

// ... typedefs defined above ...

class BackgroundDownloaderWrap {
  static Future<void> startUpload(
    String filePath,
    String url, {
    required ProgressCallback onUpdateProgress,
    required StatusCallback onUpdateStatus,
    required ErrorCallback onUploadError,
    required ResetCallback onReset,
    required CompletedCallback onUploadCompleted,
    LogCallback? log,
  }) async {
    final fileName = p.basename(filePath);
    final logPrefix = 'uploader $fileName:';

    // Check if the file exists before creating the task
    if (!File(filePath).existsSync()) {
      onUploadError(filePath, 'File not found at path: $filePath');
      log?.call('$logPrefix ERROR: File not found');
      return;
    }

    final task = UploadTask.fromFile(
      file: File(filePath),
      url: url,
      fileField: 'media',
      updates: Updates.statusAndProgress,
    );

    log?.call('$logPrefix Enqueue the task');

    try {
      final result = await FileDownloader().upload(
        task,
        onProgress: (progress) {
          log?.call('$logPrefix progress $progress');
          onUpdateProgress(filePath, progress);
        },
        onStatus: (status) {
          log?.call('$logPrefix status $status');
          onUpdateStatus(filePath, status);
        },
      );

      switch (result.status) {
        case TaskStatus.complete:
          // --- SUCCESS HANDLING ---
          final response = result.responseBody;

          if (response == null || response.isEmpty) {
            log?.call('$logPrefix failed, empty/null response');
            return onUploadError(
              filePath,
              'Server returned empty or null response',
            );
          }

          try {
            final map = jsonDecode(response) as Map<String, dynamic>;
            final identity = map['file_identifier'] as String?;

            if (identity == null) {
              log?.call('$logPrefix failed, missing identity in response');
              return onUploadError(
                filePath,
                'Server response is missing "file_identifier"',
              );
            }

            onUploadCompleted(filePath, identity, map);
          } on FormatException catch (e) {
            log?.call('$logPrefix failed, JSON decoding error: $e');
            return onUploadError(filePath, 'Invalid JSON response from server');
          } catch (e) {
            log?.call(
              '$logPrefix failed with unexpected error in response parsing: $e',
            );
            return onUploadError(
              filePath,
              'Unexpected error during response processing: ${e.runtimeType}',
            );
          }

        case TaskStatus.failed:
          log?.call('$logPrefix failed, ${result.exception}');
          onUploadError(
            filePath,
            '${result.exception ?? 'Upload failed with unknown error'}',
          );

        case TaskStatus.canceled:
          log?.call('$logPrefix cancelled');
          onReset(filePath);

        case TaskStatus.enqueued:
        case TaskStatus.running:
        case TaskStatus.notFound:
        case TaskStatus.waitingToRetry:
        case TaskStatus.paused:
          // Handles enqueued, running, notFound, waitingToRetry, paused
          log?.call(
            '$logPrefix Unexpected, returned non-finite state: ${result.status}',
          );
          // Treat non-finite states after 'await upload' as a failure for cleanup/re-try purposes
          onUploadError(
            filePath,
            'Upload process terminated unexpectedly with status: ${result.status}',
          );
      }
    } catch (e) {
      log?.call('$logPrefix Top-level exception: $e');
      onUploadError(filePath, 'System or Network Error: $e');
    }
  }

  static Future<void> cancel(String filePath) async {
    final currentTasks = await FileDownloader().allTasks();
    for (final task in currentTasks) {
      final fname = await task.filePath();
      if (fname == filePath) {
        await FileDownloader().cancelTasksWithIds([task.taskId]);
      }
    }
  }
}
