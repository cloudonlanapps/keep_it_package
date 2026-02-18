import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cl_extensions/cl_extensions.dart';

class SelectModeNotifier extends StateNotifier<bool> with CLLogger {
  SelectModeNotifier() : super(false);

  @override
  String get logPrefix => 'SelectModeNotifier';

  bool enable() {
    if (!mounted) {
      log('${TColor.red}Tried to enable after dispose');
      return false;
    }
    return state = true;
  }

  bool disable() {
    if (!mounted) {
      log('${TColor.red}Tried to disable after dispose');
      return false;
    }
    return state = false;
  }

  bool toggle() {
    if (!mounted) {
      log('${TColor.red}Tried to toggle after dispose');
      return false;
    }
    return state = !state;
  }

  @override
  void dispose() {
    log('${TColor.yellow}Disposing Selection Mode Notifier');
    super.dispose();
  }
}

final selectModeProvider = StateNotifierProvider<SelectModeNotifier, bool>((
  ref,
) {
  throw Exception("Must overide");
  // return SelectModeNotifier();
});
