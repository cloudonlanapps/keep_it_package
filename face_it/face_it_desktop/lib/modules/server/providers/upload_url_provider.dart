import 'package:cl_server_dart_client/cl_server_dart_client.dart'
    show CLServer, CLSocket;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../services/ai_server_service/ai_server_service.dart';

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
