import 'package:cl_servers/cl_servers.dart'
    show CLServer, socketConnectionProvider;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../providers/server_preference.dart';

class ConnectedServer extends ConsumerStatefulWidget {
  const ConnectedServer({required this.server, super.key});
  final CLServer server;

  @override
  ConsumerState<ConnectedServer> createState() => _ConnectedServerState();
}

class _ConnectedServerState extends ConsumerState<ConnectedServer> {
  final popoverController = ShadPopoverController();
  late Duration blinkDuration;

  @override
  void initState() {
    blinkDuration = popoverController.isOpen
        ? Duration.zero
        : const Duration(milliseconds: 500);
    super.initState();
  }

  @override
  void dispose() {
    popoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final serverPreference = ref.watch(serverPreferenceProvider);
    return ShadPopover(
      controller: popoverController,
      popover: (context) => SizedBox(
        width: 144,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ShadButton.ghost(
              expands: true,
              onPressed: () => ref
                  .read(serverPreferenceProvider.notifier)
                  .toggleAutoConnect(),
              leading: serverPreference.autoConnect
                  ? const Icon(LucideIcons.squareCheck400)
                  : const Icon(LucideIcons.square400),
              child: const Align(
                alignment: Alignment.centerLeft,
                child: Text('AutoConnect'),
              ),
            ),
            ShadButton.ghost(
              expands: true,
              leading: Icon(
                MdiIcons.lanDisconnect,
                color: ShadTheme.of(context).colorScheme.destructive,
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Disconnect',
                  style: ShadTheme.of(context).textTheme.small.copyWith(
                    color: ShadTheme.of(context).colorScheme.destructive,
                  ),
                ),
              ),
              onPressed: () {
                ref.read(serverPreferenceProvider.notifier).updateServer(null);
              },
            ),
          ],
        ),
      ),
      child: Tooltip(
        message:
            "Online. (Session autoConnect ${serverPreference.autoConnect ? 'on' : 'off'})",
        child: GestureDetector(
          onTap: popoverController.toggle,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              widget.server.storeURL.uri.toString(),
              style: ShadTheme.of(context).textTheme.small,
            ),
          ),
        ),
      ),
    );
  }
}
