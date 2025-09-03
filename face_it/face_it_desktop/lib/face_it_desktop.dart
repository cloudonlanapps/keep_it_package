import 'dart:io';

import 'package:colan_widgets/colan_widgets.dart';
import 'package:face_it_desktop/cl_browser_panel/views/cl_browser_panel_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'providers/image_provider.dart';
import 'views/image_browser.dart';
import 'cl_browser_panel/models/cl_browser_panal.dart';
import 'cl_browser_panel/providers/cl_browser_panal.dart';
import 'views/log_view.dart';
import 'providers/server_io.dart';

class FaceItDesktop extends ConsumerWidget {
  const FaceItDesktop({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ShadTheme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text("Detect Faces")),
      body: ProviderScope(
        overrides: [
          clBrowserPanalProvider.overrideWith(
            (ref) => CLBrowserPanalNotifier(
              CLBrowserPanals(
                activePanelLabel: "Images",
                availablePanels: [
                  CLBrowserPanal(
                    label: "Images",
                    panelBuilder: (context) => ImageBrowser(),
                  ),
                  CLBrowserPanal(label: "Faces"),
                ],
              ),
            ),
          ),
        ],
        child: MainScreen(),
      ),
    );
  }
}

class MainScreen extends ConsumerWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        Divider(color: ShadTheme.of(context).colorScheme.muted, height: 1),
        Expanded(
          child: ShadResizablePanelGroup(
            children: [
              ShadResizablePanel(
                id: 'explorer',
                defaultSize: .2,
                minSize: .1,
                maxSize: .2,
                child: CLBrowserPanelView(),
              ),
              ShadResizablePanel(
                id: 'mainPanel',
                defaultSize: .6,
                minSize: .2,

                child: ActiveImage(),
              ),
              ShadResizablePanel(
                id: 'logView',
                defaultSize: .2,
                minSize: .1,
                child: Container(
                  decoration: BoxDecoration(color: Colors.black87),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(child: SocketConnectButton()),
                      ),
                      Divider(color: Colors.white, height: 1),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: LogView(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ActiveImage extends ConsumerWidget {
  const ActiveImage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final menuItems = [
      CLMenuItem(title: "Recognize Faces", icon: Icons.abc),
      CLMenuItem(title: "Extract Text", icon: Icons.abc),
      CLMenuItem(title: "Scan Objects", icon: Icons.abc),
    ];
    return ref
        .watch(availableMediaProvider)
        .when(
          data: (data) {
            return Column(
              children: [
                if (data.activeMedia == null)
                  Center(
                    child: Text(
                      "Select a Media",
                      style: ShadTheme.of(context).textTheme.muted,
                    ),
                  )
                else ...[
                  ImageMenu(menuItems: menuItems),
                  Expanded(
                    child: Image.file(File(data.activeMedia!.path), width: 256),
                  ),
                ],
              ],
            );
          },
          error: (_, __) => Container(),
          loading: () => Container(),
        );
  }
}

class ImageMenu extends StatelessWidget {
  const ImageMenu({super.key, required this.menuItems});

  final List<CLMenuItem> menuItems;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SocketConnectButton(),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: menuItems
                  .map(
                    (e) => Expanded(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: MenuLinkActiveWhenSocketConnected(menuItem: e),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class SocketConnectButton extends ConsumerWidget {
  const SocketConnectButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final serverIO = ref.watch(sessionProvider).whenOrNull(data: (io) => io);

    // If serverIO is null, the button is disabled and shows "Connect".
    if (serverIO == null) {
      return const ShadButton(
        enabled: false,
        onPressed: null,
        child: Text("abc"),
      );
    }

    // Determine button text and action based on connection status.
    final bool isConnected = serverIO.socket.connected;
    final String buttonText = isConnected ? "Disconnect" : "Connect";
    final VoidCallback onPressed = isConnected
        ? serverIO.socket.disconnect
        : serverIO.socket.connect;

    return ShadButton(
      enabled: true,
      onPressed: onPressed,
      child: Text(buttonText),
    );
  }
}
//"Scan Objects"

class MenuLinkActiveWhenSocketConnected extends ConsumerWidget {
  const MenuLinkActiveWhenSocketConnected({super.key, required this.menuItem});

  final CLMenuItem menuItem;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final serverIO = ref.watch(sessionProvider).whenOrNull(data: (io) => io);
    return ShadButton.link(
      enabled: serverIO?.socket.connected ?? false,
      child: Text(
        menuItem.title,
        maxLines: 2,
        textAlign: TextAlign.center,
        softWrap: true,
      ),
    );
  }
}

class MenuButtonActiveWhenSocketConnected extends ConsumerWidget {
  const MenuButtonActiveWhenSocketConnected({
    super.key,
    required this.menuItem,
  });

  final CLMenuItem menuItem;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final serverIO = ref.watch(sessionProvider).whenOrNull(data: (io) => io);
    return ShadButton.outline(
      enabled: serverIO?.socket.connected ?? false,
      child: Text(
        menuItem.title,
        maxLines: 2,
        textAlign: TextAlign.center,
        softWrap: true,
      ),
    );
  }
}
