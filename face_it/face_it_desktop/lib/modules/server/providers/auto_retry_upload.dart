import 'package:cl_basic_types/cl_basic_types.dart';
import 'package:cl_servers/cl_servers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../uploader/providers/uploader.dart';

class AutoRetryUpload with CLLogger {
  // Call this function only inside a build
  void watch(WidgetRef ref) {
    ref
      ..listen(socketConnectionProvider, (prev, curr) {
        /* final wasConnected =
          prev?.whenOrNull(data: (data) => data.socket.connected) ?? false; */
        final isConnected =
            curr.whenOrNull(data: (data) => data.socket.connected) ?? false;
        final wasConnected = !isConnected;
        log(
          'listening socketConnectionProvider: wasConnected: $wasConnected, isConnected: $isConnected',
        );

        // If the socket disconnected, reset all uploads
        if (wasConnected && !isConnected) {
          // Disconnected
          log('listening socketConnectionProvider:  Uploader reset');
          ref.read(uploaderProvider.notifier).reset();
        } else if (!wasConnected && isConnected) {
          // Connected
          log('listening socketConnectionProvider:  Uploader retry');
          ref.read(uploaderProvider.notifier).retry();
        }
      })
      ..listen(uploaderProvider, (prev, curr) {
        log(
          'listening uploaderProvider: UploaderNotifier has ${curr.whenOrNull(data: (data) => data)?.count} items now; was having ${prev?.whenOrNull(data: (data) => data)?.count} items',
        );
      });
  }

  @override
  String get logPrefix => 'AutoRetryUpload';
}
