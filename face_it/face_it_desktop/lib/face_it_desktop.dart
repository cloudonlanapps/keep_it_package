import 'dart:io';

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

class FaceItDesktop extends ConsumerStatefulWidget {
  const FaceItDesktop({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _FaceItDesktopState();
}

class _FaceItDesktopState extends ConsumerState<FaceItDesktop> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.read(serverIOProvider.notifier);

    final isConnected = ref
        .watch(serverIOProvider)
        .whenOrNull(data: (serverIO) => serverIO.isConnected);
    ShadTheme.of(context);
    return ProviderScope(
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
      child: Scaffold(
        appBar: AppBar(title: const Text("Detect Faces")),
        body: Column(
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
                            child: Center(
                              child: ElevatedButton(
                                onPressed: isConnected == null
                                    ? null
                                    : isConnected
                                    ? notifier.disconnectFromServer
                                    : notifier.connect,
                                child: Text(
                                  isConnected == null
                                      ? "Wait"
                                      : isConnected
                                      ? "Disconnect"
                                      : "Connect",
                                ),
                              ),
                            ),
                          ),
                          Divider(color: Colors.white, height: 1),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8.0,
                              ),
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
        ),
      ),
    );
  }
}

class ActiveImage extends ConsumerWidget {
  const ActiveImage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref
        .watch(availableMediaProvider)
        .when(
          data: (data) {
            if (data.activeMedia == null) {
              return Center(
                child: Text(
                  "Select a Media",
                  style: ShadTheme.of(context).textTheme.muted,
                ),
              );
            }
            return Column(
              children: [
                ref
                    .watch(serverIOProvider)
                    .when(
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (err, stack) => Center(child: Text("Error: $err")),
                      data: (serverIO) {
                        final notifier = ref.read(serverIOProvider.notifier);
                        final isConnected = serverIO.isConnected;
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              ShadButton(
                                onPressed: isConnected
                                    ? notifier.disconnectFromServer
                                    : notifier.connect,
                                child: Text(
                                  isConnected ? "Disconnect" : "Connect",
                                ),
                              ),
                              Expanded(
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Expanded(
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: ShadButton.link(
                                          enabled: isConnected,
                                          child: Text(
                                            "Recognize Faces",
                                            maxLines: 2,
                                            textAlign: TextAlign.center,
                                            softWrap: true,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: ShadButton.link(
                                          enabled: isConnected,
                                          child: Text(
                                            "Extract Text",
                                            maxLines: 2,
                                            textAlign: TextAlign.center,
                                            softWrap: true,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: ShadButton.link(
                                          enabled: isConnected,
                                          child: Text(
                                            "Scan Objects",
                                            maxLines: 2,
                                            textAlign: TextAlign.center,
                                            softWrap: true,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: ShadButton.link(
                                          enabled: isConnected,
                                          child: Text(
                                            "Generate Caption",
                                            maxLines: 2,
                                            textAlign: TextAlign.center,
                                            softWrap: true,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                Expanded(
                  child: Image.file(File(data.activeMedia!.path), width: 256),
                ),
              ],
            );
          },
          error: (_, __) => Container(),
          loading: () => Container(),
        );
  }
}
