import 'package:cl_servers/cl_servers.dart' show CLServer;
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'providers/preferred_ai_server.dart';

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
              leading: Icon(
                MdiIcons.lanDisconnect,
                color: ShadTheme.of(context).colorScheme.destructive,
              ),
              child: const Align(
                alignment: Alignment.centerLeft,
                child: Text('Disconnect'),
              ),
              onPressed: () =>
                  ref.read(preferredServerIdProvider.notifier).state = null,
            ),
            ShadButton.ghost(
              expands: true,
              leading: Icon(
                MdiIcons.check,
                color: ShadTheme.of(context).colorScheme.destructive,
              ),
              child: const Align(
                alignment: Alignment.centerLeft,
                child: Text('AutoConnect'),
              ),
            ),
          ],
        ),
      ),
      child: GestureDetector(
        onTap: popoverController.toggle,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Text(
            widget.server.storeURL.uri.toString(),
            style: ShadTheme.of(context).textTheme.small,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
