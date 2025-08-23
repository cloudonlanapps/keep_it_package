import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'views/log_view.dart';
import 'providers/server_io.dart';

class WebSocketDemo extends ConsumerWidget {
  const WebSocketDemo({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(serverIOProvider.notifier);

    final isConnected = ref
        .watch(serverIOProvider)
        .whenOrNull(data: (serverIO) => serverIO.isConnected);
    ShadTheme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text("WebSocket Demo")),
      body: ShadResizablePanelGroup(
        children: [
          ShadResizablePanel(
            id: 0,
            defaultSize: .7,
            minSize: .2,
            child: Center(
              child: ElevatedButton(
                onPressed: isConnected == true ? notifier.sendProcess : null,
                child: const Text("Send Process"),
              ),
            ),
          ),
          ShadResizablePanel(
            id: 1,
            defaultSize: .3,
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
    );
  }
}
