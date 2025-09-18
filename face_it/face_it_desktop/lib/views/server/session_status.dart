import 'package:cl_servers/cl_servers.dart' show GetServerSession;
import 'package:face_it_desktop/views/server/providers/preferred_ai_server.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class SessionStatus extends ConsumerWidget {
  const SessionStatus({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textStyle = ShadTheme.of(context).textTheme.small.copyWith(
      color: ShadTheme.of(context).textTheme.muted.color,
      fontSize: ShadTheme.of(context).textTheme.small.fontSize != null
          ? ShadTheme.of(context).textTheme.small.fontSize! - 4
          : ShadTheme.of(context).textTheme.small.fontSize,
    );
    final serverPref = ref.watch(serverPreferenceProvider);

    return GetServerSession(
      serverUri: serverPref,
      builder: (session) {
        if (session == null) return const SizedBox.shrink();
        return Text.rich(
          TextSpan(
            children: [
              TextSpan(text: 'AI Serice: ', style: textStyle),
              if (session.socket.connected)
                TextSpan(
                  text: 'Connected \nid: ${session.socket.id}',
                  style: textStyle.copyWith(color: Colors.lightGreen),
                )
              else
                TextSpan(text: 'Disconnected\n', style: textStyle),
            ],
          ),
        );
      },
    );
  }
}
