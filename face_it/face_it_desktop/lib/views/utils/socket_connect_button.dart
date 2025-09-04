import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../providers/d_session_provider.dart';
import '../../providers/e_preferred_server.dart';

class SocketConnectButton extends ConsumerWidget {
  const SocketConnectButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final serverIO = ref.watch(sessionProvider).whenOrNull(data: (io) => io);

    // If serverIO is null, the button is disabled and shows "Connect".
    if (serverIO == null) {
      return const ShadButton(enabled: false, child: Text('abc'));
    }

    // Determine button text and action based on connection status.
    final isConnected = serverIO.socket.connected;
    final buttonText = isConnected ? 'Disconnect' : 'Connect';
    final onPressed = isConnected
        ? () {
            serverIO.socket.disconnect();
            ref.read(preferredServerIdProvider.notifier).state = null;
          }
        : serverIO.socket.connect;

    return ShadButton(onPressed: onPressed, child: Text(buttonText));
  }
}
