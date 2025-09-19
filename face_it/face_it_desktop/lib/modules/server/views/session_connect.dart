import 'package:cl_servers/cl_servers.dart'
    show GetServerSession, socketConnectionProvider;
import 'package:face_it_desktop/modules/server/providers/server_preference.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class SessionConnect extends ConsumerWidget {
  const SessionConnect({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final serverPref = ref.watch(serverPreferenceProvider);

    ref
      ..listen(socketConnectionProvider(serverPref), (prev, curr) {
        if (serverPref.autoConnect) {
          final session = curr.whenOrNull(data: (data) => data);

          if (session != null && !session.socket.connected) {
            session.socket.connect();
          }
        }
      })
      ..listen(serverPreferenceProvider, (prev, curr) {
        final sessionAsync = ref.read(socketConnectionProvider(curr));
        final session = sessionAsync.whenOrNull(data: (data) => data);

        if (session != null && !session.socket.connected) {
          session.socket.connect();
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
                  ? 'auto-connect'
                  : session.socket.connected
                  ? 'disconnect'
                  : 'connect',
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
