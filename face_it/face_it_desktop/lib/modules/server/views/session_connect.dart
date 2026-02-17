import 'dart:async';

import 'package:colan_services/server_service/server_service.dart'
    show serverPreferenceProvider;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../services/ai_server_service/ai_server_service.dart';
import '../../uploader/providers/uploader.dart';

class SessionConnect extends ConsumerWidget {
  const SessionConnect({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final serverPref = ref.watch(serverPreferenceProvider);

    return GetServerSession(
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
                  unawaited(
                    ref
                        .read(uploaderProvider.notifier)
                        .cancelAllTasks()
                        .then((_) => session.socket.disconnect()),
                  );
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
