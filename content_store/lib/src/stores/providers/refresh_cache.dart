import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';

class ReloadNotifier extends Notifier<String> {
  @override
  String build() {
    listenSelf((prev, curr) {
      log(
        'Trigger Refresh at $curr',
        name: 'refreshReaderProvider',
        time: DateTime.now(),
      );
    });

    // Return the initial state
    return DateTime.now().toIso8601String();
  }

  void reload() {
    state = DateTime.now().toIso8601String();
  }
}

final reloadProvider = NotifierProvider<ReloadNotifier, String>(
  ReloadNotifier.new,
);
