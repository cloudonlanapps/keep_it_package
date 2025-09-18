import 'package:cl_servers/cl_servers.dart'
    show GetActiveAIServer, GetAvailableServers;
import 'package:face_it_desktop/views/server/providers/server_preference.dart';
import 'package:face_it_desktop/views/server/views/connected_server.dart';
import 'package:face_it_desktop/views/server/views/server_select.dart';
import 'package:face_it_desktop/views/server/views/session_connect.dart';
import 'package:face_it_desktop/views/server/views/session_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class ServerManageView extends ConsumerWidget {
  const ServerManageView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final serverPreference = ref.watch(serverPreferenceProvider);
    const loadingWidget = Center(
      child: CircularProgressIndicator(color: Colors.blue),
    );
    const errorWidget = Center(child: Icon(LucideIcons.triangleAlert));

    return GetActiveAIServer(
      serverURI: serverPreference,
      builder: (activeAIServer) {
        return GetAvailableServers(
          serverType: 'ai.',
          loadingBuilder: () => loadingWidget,
          errorBuilder: (p0, p1) => errorWidget,
          builder: (servers) {
            return ListTile(
              title: servers.isEmpty
                  ? Text(
                      'Server Not Available',
                      style: ShadTheme.of(context).textTheme.small,
                      textAlign: TextAlign.end,
                    )
                  : activeAIServer != null
                  ? ConnectedServer(server: activeAIServer)
                  : null,
              subtitle: const SessionStatus(),
              leading: const ShadAvatar(
                'assets/icon/cloud_on_lan_128px_color.png',
                backgroundColor: Colors.transparent,
                size: Size.fromRadius((kMinInteractiveDimension / 2) - 6),
              ),
              trailing: (activeAIServer != null)
                  ? const SessionConnect()
                  : servers.isEmpty
                  ? const ShadButton.ghost(
                      leading: CircularProgressIndicator.adaptive(),
                    )
                  : ServerSelect(servers: servers),
            );
          },
        );
      },
    );
  }
}
