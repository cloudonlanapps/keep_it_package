import 'dart:async';

import 'package:cl_basic_types/cl_basic_types.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ServerNotifier extends FamilyAsyncNotifier<CLServer, CLUrl>
    with CLLogger {
  @override
  String get logPrefix => 'ServerNotifier';

  Timer? timer;

  @override
  FutureOr<CLServer> build(CLUrl arg) async {
    try {
      final clServer = await CLServer(storeURL: arg).isConnected();

      timer = Timer.periodic(const Duration(seconds: 5), monitorServer);

      ref.onDispose(() {
        timer?.cancel();
        timer = null;
      });

      state = AsyncData(clServer);
      return clServer;
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<void> monitorServer(Timer _) async {
    try {
      final clServer = await state.value?.isConnected();
      final server = state.value;

      if (server != clServer) {
        state = AsyncData(clServer!);
      }
    } catch (e) {
      log('monitorServer: $e');
      rethrow;
    }
  }
}

final serverProvider =
    AsyncNotifierProviderFamily<ServerNotifier, CLServer, CLUrl>(
        ServerNotifier.new);
