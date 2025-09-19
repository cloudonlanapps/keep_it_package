import 'package:cl_basic_types/cl_basic_types.dart';
import 'package:cl_servers/cl_servers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AutoConnectMonitor with CLLogger {
  // Call this function only inside a build
  void watch(WidgetRef ref) {
    ref
      ..listen(socketConnectionProvider, (prev, curr) {
        final autoConnect = ref.read(
          serverPreferenceProvider.select((e) => e.autoConnect),
        );
        final before = prev?.whenOrNull(data: (data) => data);
        final now = curr.whenOrNull(data: (data) => data);

        log(
          'listening socketConnectionProvider: autoConnect=$autoConnect, session Active: ${now?.socket.connected ?? false}',
        );
        if (autoConnect &&
            before == null &&
            now != null &&
            !now.socket.connected) {
          log(
            'listening socketConnectionProvider: connecting as autoConnect is enabled',
          );
          now.socket.connect();
        }
      })
      ..listen(serverPreferenceProvider.select((e) => e.autoConnect), (
        prev,
        autoConnect,
      ) {
        final session = ref
            .read(socketConnectionProvider)
            .whenOrNull(data: (data) => data);
        log(
          'listening serverPreferenceProvider: autoConnect=$autoConnect, session Active: ${session?.socket.connected ?? false}',
        );
        if (prev != autoConnect &&
            autoConnect &&
            session != null &&
            (!session.socket.connected)) {
          log(
            'listening serverPreferenceProvider: connecting as autoConnect is enabled',
          );
          session.socket.connect();
        }
      });
  }

  @override
  String get logPrefix => 'AutoConnectMonitor';
}
