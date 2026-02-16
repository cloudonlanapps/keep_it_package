import 'package:cl_server_services/cl_server_services.dart'
    show CLServer, serverPreferenceProvider;
import 'package:colan_widgets/colan_widgets.dart';
import 'package:face_it_desktop/modules/server/views/server_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class ServerSelect extends ConsumerStatefulWidget {
  const ServerSelect({required this.servers, super.key});
  final List<CLServer> servers;

  @override
  ConsumerState<ServerSelect> createState() => ServerSelectorIconState();
}

class ServerSelectorIconState extends ConsumerState<ServerSelect> {
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
                        .updateServer(e.locationConfig.uri);

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
