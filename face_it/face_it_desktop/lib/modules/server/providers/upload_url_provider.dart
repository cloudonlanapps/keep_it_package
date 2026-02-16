import 'package:colan_services/server_service/server_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final uploadURLProvider = StateProvider<String?>((ref) {
  CLSocket? session;
  CLServer? server;
  session = ref
      .watch(socketConnectionProvider)
      .whenOrNull(data: (data) => data.socket.connected ? data : null);
  server = ref
      .watch(activeAIServerProvider)
      .whenOrNull(data: (data) => (data?.connected ?? false) ? data : null);
  if (server != null && session != null && session.socket.connected) {
    return '${server.locationConfig.uri}/sessions/${session.socket.id}/upload';
  }
  return null;
});
