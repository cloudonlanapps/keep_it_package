import 'package:colan_widgets/colan_widgets.dart';
import 'package:face_it_desktop/providers/server_io.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class MenuLinkActiveWhenSocketConnected extends ConsumerWidget {
  const MenuLinkActiveWhenSocketConnected({required this.menuItem, super.key});

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
