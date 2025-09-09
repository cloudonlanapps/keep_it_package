import 'package:cl_servers/cl_servers.dart' show CLServer, GetAvailableServers;
import 'package:colan_widgets/colan_widgets.dart';

import 'package:face_it_desktop/providers/d_online_server.dart';
import 'package:face_it_desktop/providers/d_session_provider.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../providers/e_preferred_server.dart';

class ServerSelector extends ConsumerWidget {
  const ServerSelector({required this.onDone, super.key});

  final void Function(CLServer server)? onDone;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const loadingWidget = Center(child: CircularProgressIndicator.adaptive());
    const errorWidget = Center(child: Icon(LucideIcons.triangleAlert));
    final activeAIServer = ref
        .watch(activeAIServerProvider)
        .whenOrNull(data: (io) => io);

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
                  textAlign: servers.isEmpty ? TextAlign.center : TextAlign.end,
                )
              : activeAIServer != null
              ? Text(
                  activeAIServer.storeURL.uri.toString(),
                  style: ShadTheme.of(context).textTheme.small,
                  textAlign: servers.isEmpty ? TextAlign.center : TextAlign.end,
                )
              : null,
          leading: const ShadAvatar(
            'assets/icon/cloud_on_lan_128px_color.png',
            backgroundColor: Colors.transparent,
            size: Size.fromRadius((kMinInteractiveDimension / 2) - 6),
          ),
          trailing: servers.isEmpty
              ? const ShadButton.ghost(
                  leading: CircularProgressIndicator.adaptive(),
                )
              : ServerSelectorIcon(servers: servers),
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
    final clServer = ref
        .watch(activeAIServerProvider)
        .whenOrNull(data: (io) => io);
    final session = ref.watch(sessionProvider).whenOrNull(data: (io) => io);

    if (clServer != null) {
      if (!(session?.socket.connected ?? true)) {
        return const ShadButton.ghost(
          leading: CircularProgressIndicator.adaptive(),
        );
      } else {
        return ShadButton.ghost(
          leading: clIcons.disconnectToServer.iconFormatted(
            color: ShadTheme.of(context).colorScheme.destructive,
          ),
          onPressed: () {
            session?.socket.disconnect();

            ref.read(preferredServerIdProvider.notifier).state = null;
          },
        );
      }
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
                  onPressed: () {
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
        child: clServer == null ? const Text('Select Server') : null /* , */,
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
