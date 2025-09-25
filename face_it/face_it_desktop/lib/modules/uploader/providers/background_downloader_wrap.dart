import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:background_downloader/background_downloader.dart';
import 'package:path/path.dart' as p;

class BackgroundDownloaderWrap {
  static Future<void> startUpload(
    String filePath,
    String url, {
    required void Function(String filePath, double progress) onUpdateProgress,
    required void Function(String filePath, TaskStatus status) onUpdateStatus,
    required void Function(String filePath, String error) onUploadError,
    required void Function(String filePath) onReset,
    required void Function(
      String filePath,
      String identity,
      Map<String, dynamic> map,
    )
    onUploadCompleted,
    void Function(String msg)? log,
  }) async {
    final fileName = p.basename(filePath);
    final logPrefix = 'uploader $fileName:';
    final task = UploadTask.fromFile(
      file: File(filePath),
      url: url,
      fileField: 'media',
      updates: Updates.statusAndProgress,
    );

    log?.call('$logPrefix Enqueue the task');

    await FileDownloader()
        .upload(
          task,

          onProgress: (progress) {
            log?.call('$logPrefix progress $progress');
            onUpdateProgress(filePath, progress);
          },
          onStatus: (status) {
            log?.call('$logPrefix status $status');
            onUpdateStatus(filePath, status);
          },
        )
        .catchError((dynamic e) async {
          log?.call('$logPrefix catchError: Exception $e');

          return TaskStatusUpdate(task, TaskStatus.failed, TaskException('$e'));
        })
        .then((result) {
          switch (result.status) {
            case TaskStatus.enqueued:
            case TaskStatus.running:
            case TaskStatus.notFound:
            case TaskStatus.waitingToRetry:
            case TaskStatus.paused:
              log?.call('$logPrefix Unexpected, returning non finite state');
              throw Exception('returned a non finite state');
            case TaskStatus.failed:
              log?.call('$logPrefix failed, ${result.exception}');
              onUploadError(filePath, '${result.exception}');
            case TaskStatus.canceled:
              log?.call('$logPrefix cancelled');
              onReset(filePath);
            case TaskStatus.complete:
              final response = result.responseBody;
              if (response == null) {
                log?.call('$logPrefix failed, null response');
                onUploadError(filePath, 'Null Response');
              } else if (response.isEmpty) {
                log?.call('$logPrefix failed, empty response');
                onUploadError(
                  filePath,
                  '${result.exception ?? 'Empty Response'}',
                );
              } else {
                try {
                  final map = jsonDecode(response);
                  final identity =
                      (map as Map<String, dynamic>?)?['file_identifier']
                          as String?;
                  if (identity == null) {
                    return onUploadError(filePath, 'missing identity');
                  }
                  onUploadCompleted(filePath, identity, map!);
                } catch (e) {
                  return onUploadError(
                    filePath,
                    'invalid response from server',
                  );
                }
              }
          }
        });
  }
}
