import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../stores/builders/get_active_store.dart';
import '../stores/providers/active_store_provider.dart';

class ServerBar extends ConsumerWidget {
  const ServerBar({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showText = ref.watch(serverBarStatusProvider);
    ref.listen(activeStoreProvider, (prev, curr) {
      ref.read(serverBarStatusProvider.notifier).on();
    });

    return GetActiveStore(
      errorBuilder: (_, _) => const SizedBox.shrink(),
      loadingBuilder: SizedBox.shrink,
      builder: (activeServer) {
        return ShadBadge(
          padding: const EdgeInsets.only(left: 2, right: 2, top: 2, bottom: 2),
          onPressed: () => ref.read(serverBarStatusProvider.notifier).toggle(),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 8,
            children: [
              ShadAvatar(
                (activeServer.store.isLocal)
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
        );
      },
    );
  }
}

class ServerBarStatusNotifier extends StateNotifier<bool> {
  ServerBarStatusNotifier() : super(false);
  Timer? timer;

  void toggle() {
    switch (state) {
      case true:
        off();
      case false:
        on();
    }
  }

  void on() {
    timer?.cancel();
    state = true;
    timer = Timer(const Duration(seconds: 2), () {
      if (state) {
        state = false;
      }
    });
  }

  void off() {
    timer?.cancel();
    state = false;
  }

  @override
  void dispose() {
    timer?.cancel();
    timer = null;
    super.dispose();
  }
}

final serverBarStatusProvider =
    StateNotifierProvider<ServerBarStatusNotifier, bool>((ref) {
      return ServerBarStatusNotifier();
    });
