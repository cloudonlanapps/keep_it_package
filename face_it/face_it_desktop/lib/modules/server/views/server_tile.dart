import 'package:cl_server_dart_client/cl_server_dart_client.dart' show CLServer;
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class ServerTile extends ConsumerWidget {
  const ServerTile({required this.server, required this.onPressed, super.key});
  final CLServer server;
  final void Function() onPressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locationConfig = server.locationConfig;
    final IconData icon;
    final Color? color;

    if (server.connected) {
      // LucideIcons.circle
      icon = LucideIcons.circleCheck;
      color = null;
    } else {
      icon = clIcons.noNetwork;
      color = Colors.red;
    }
    return ListTile(
      leading: Icon(icon, color: color),
      enabled: server.connected,
      title: Text(
        locationConfig.label ?? locationConfig.displayName,
        style: ShadTheme.of(context).textTheme.small,
      ),
      onTap: onPressed,
    );
  }
}
