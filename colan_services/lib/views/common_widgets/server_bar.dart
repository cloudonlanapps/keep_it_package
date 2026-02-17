import 'dart:async';

import 'package:colan_services/colan_services.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class ServerBar extends StatefulWidget {
  const ServerBar({super.key});

  @override
  State<ServerBar> createState() => _ServerBarState();
}

class _ServerBarState extends State<ServerBar> {
  bool showText = false;
  Timer? _timer;

  void toggle() {
    setState(() => showText = !showText);
    _timer?.cancel();
    if (showText) {
      _timer = Timer(const Duration(seconds: 2), () {
        if (mounted) setState(() => showText = false);
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetActiveStore(
      errorBuilder: (_, _) => const SizedBox.shrink(),
      loadingBuilder: SizedBox.shrink,
      builder: (activeServer) => ShadBadge(
        padding: const EdgeInsets.only(left: 2, right: 2, top: 2, bottom: 2),
        onPressed: toggle,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 8,
          children: [
            ShadAvatar(
              (activeServer.entityStore.isLocal)
                  ? 'assets/icon/not_on_server.png'
                  : 'assets/icon/cloud_on_lan_128px_color.png',
              size: const Size.fromRadius((kMinInteractiveDimension / 2) - 6),
            ),
            if (showText)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Text(activeServer.label),
              ),
          ],
        ),
      ),
    );
  }
}
