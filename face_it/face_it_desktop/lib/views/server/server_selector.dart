import 'package:cl_servers/cl_servers.dart'
    show CLServer, GetActiveAIServer, GetAvailableServers, GetServerSession;
import 'package:colan_widgets/colan_widgets.dart';
import 'package:face_it_desktop/views/server/connected_server.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'providers/preferred_ai_server.dart';

class ServerSelector extends ConsumerWidget {
  const ServerSelector({required this.onDone, super.key});

  final void Function(CLServer server)? onDone;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final serverURI = ref.watch(preferredServerIdProvider);
    const loadingWidget = Center(
      child: CircularProgressIndicator(color: Colors.blue),
    );
    const errorWidget = Center(child: Icon(LucideIcons.triangleAlert));

    return GetActiveAIServer(
      serverURI: serverURI,
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
                      style: ShadTheme.of(context).textTheme.p,
                      textAlign: TextAlign.end,
                    )
                  : activeAIServer != null
                  ? ConnectedServer(server: activeAIServer)
                  : null,
              leading: const ShadAvatar(
                'assets/icon/cloud_on_lan_128px_color.png',
                backgroundColor: Colors.transparent,
                size: Size.fromRadius((kMinInteractiveDimension / 2) - 6),
              ),
              trailing: servers.isEmpty
                  ? const ShadButton.ghost(
                      leading: CircularProgressIndicator(color: Colors.red),
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
  late Duration blinkDuration;

  @override
  void initState() {
    popoverController.addListener(listener);
    blinkDuration = popoverController.isOpen
        ? Duration.zero
        : const Duration(milliseconds: 500);
    super.initState();
  }

  @override
  void dispose() {
    popoverController
      ..removeListener(listener)
      ..dispose();

    super.dispose();
  }

  void listener() {
    setState(() {
      blinkDuration = popoverController.isOpen
          ? Duration.zero
          : const Duration(milliseconds: 500);
    });
  }

  @override
  Widget build(BuildContext context) {
    final serverURI = ref.watch(preferredServerIdProvider);
    return GetActiveAIServer(
      serverURI: serverURI,
      builder: (clServer) {
        return GetServerSession(
          serverUri: serverURI,
          builder: (session) {
            if (clServer != null) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ShadButton.ghost(
                    leading: clIcons.disconnectToServer.iconFormatted(
                      color: ShadTheme.of(context).colorScheme.destructive,
                    ),
                    onPressed: () async {},
                  ),
                ],
              );
            }
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
                            ref.read(preferredServerIdProvider.notifier).state =
                                e.storeURL.uri;

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
                child: clServer == null
                    ? const Text('Select Server')
                    : null /* , */,
              ),
            );
          },
        );
      },
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
