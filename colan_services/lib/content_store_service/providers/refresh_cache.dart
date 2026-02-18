import 'package:cl_extensions/cl_extensions.dart' show CLLogger;
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ReloadNotifier extends Notifier<String> with CLLogger {
  @override
  String build() {
    listenSelf((prev, curr) {
      log('Trigger Refresh at $curr');
    });

    // Return the initial state
    return DateTime.now().toIso8601String();
  }

  void reload() {
    state = DateTime.now().toIso8601String();
  }

  @override
  String get logPrefix => 'ReloadNotifier';
}

final reloadProvider = NotifierProvider<ReloadNotifier, String>(
  ReloadNotifier.new,
);
