import 'package:cl_servers/cl_servers.dart'
    show
        CLServer,
        GetActiveAIServer,
        GetAvailableServers,
        GetServerSession,
        socketConnectionProvider;
import 'package:colan_widgets/colan_widgets.dart';
import 'package:face_it_desktop/views/server/connected_server.dart';
import 'package:face_it_desktop/views/server/session_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'providers/preferred_ai_server.dart';

class ServerSelector extends ConsumerWidget {
  const ServerSelector({super.key});

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
                  ? const SessionConnectIcon()
                  : servers.isEmpty
                  ? const ShadButton.ghost(
                      leading: CircularProgressIndicator.adaptive(),
                    )
                  : ServerSelectorIcon(servers: servers),
            );
          },
        );
      },
    );
  }
}

class ServerSelectorIcon extends ConsumerStatefulWidget {
  const ServerSelectorIcon({required this.servers, super.key});
  final List<CLServer> servers;

  @override
  ConsumerState<ServerSelectorIcon> createState() => ServerSelectorIconState();
}

class ServerSelectorIconState extends ConsumerState<ServerSelectorIcon> {
  final popoverController = ShadPopoverController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    popoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ShadPopover(
      controller: popoverController,
      popover: (context) => SizedBox(
        width: 288,
        child: ListView(
          shrinkWrap: true,
          children: widget.servers
              .map(
                (e) => ServerTile(
                  server: e,
                  onPressed: () async {
                    ref
                        .read(serverPreferenceProvider.notifier)
                        .updateServer(e.storeURL.uri);

                    popoverController.toggle();
                  },
                ),
              )
              .toList(),
        ),
      ),
      child: ShadButton.ghost(
        leading: clIcons.connectToServer.iconFormatted(),
        onPressed: popoverController.toggle,
        child: Text(
          'Select Server',
          style: ShadTheme.of(context).textTheme.small,
        ),
      ),
    );
  }
}

class ServerTile extends ConsumerWidget {
  const ServerTile({required this.server, required this.onPressed, super.key});
  final CLServer server;
  final void Function() onPressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storeURL = server.storeURL;
    final IconData icon;
    final Color? color;

    if (server.connected) {
      // LucideIcons.circle
      icon = LucideIcons.circleCheck;
      color = null;
    } else {
      icon = clIcons.noNetwork;
      color = Colors.red;
    }
    return ListTile(
      leading: Icon(icon, color: color),
      enabled: server.connected,
      title: Text(
        storeURL.label ?? storeURL.name,
        style: ShadTheme.of(context).textTheme.small,
      ),
      onTap: onPressed,
    );
  }
}

class SessionConnectIcon extends ConsumerWidget {
  const SessionConnectIcon({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final serverPref = ref.watch(serverPreferenceProvider);
    print('SessionConnectIcon');
    ref.listen(socketConnectionProvider(serverPref), (prev, curr) {
      if (serverPref.autoConnect) {
        final session = curr.whenOrNull(data: (data) => data);
        print('isSession Connected? ${session?.connected}');
        if (session != null && !session.socket.connected) {
          print('connecting');
          session.socket.connect();
        }
      }
    });
    return GetServerSession(
      serverUri: serverPref,
      builder: (session) {
        if (session == null) {
          return Tooltip(
            message: 'Server is not available. Try connecting to server',
            child: Icon(
              LucideIcons.triangleAlert400,
              color: ShadTheme.of(context).colorScheme.destructive,
            ),
          );
        }
        final textStyle = ShadTheme.of(context).textTheme.small.copyWith(
          color: ShadTheme.of(context).textTheme.muted.color,
          fontSize: ShadTheme.of(context).textTheme.small.fontSize != null
              ? ShadTheme.of(context).textTheme.small.fontSize! - 4
              : ShadTheme.of(context).textTheme.small.fontSize,
        );
        return Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 4,
          children: [
            Text(
              serverPref.autoConnect
                  ? session.socket.connected
                        ? 'Connected'
                        : 'Disconnected'
                  : session.socket.connected
                  ? 'Disconnect'
                  : 'Connect',
              style: textStyle,
            ),
            ShadSwitch(
              enabled: !serverPref.autoConnect,
              value: session.socket.connected,
              onChanged: (v) {
                if (session.socket.connected) {
                  session.socket.disconnect();
                } else {
                  session.socket.connect();
                }
              },
            ),
          ],
        );
      },
    );
  }
}
