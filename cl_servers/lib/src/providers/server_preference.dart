import 'package:cl_servers/cl_servers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final serverPreferenceProvider =
    StateNotifierProvider<ServerPreferenceNotifier, ServerPreferences>((ref) {
      return ServerPreferenceNotifier();
    });

class ServerPreferenceNotifier extends StateNotifier<ServerPreferences> {
  ServerPreferenceNotifier() : super(const ServerPreferences());

  void updateServer(Uri? uri) {
    state = state.copyWith(uri: () => uri);
  }

  void toggleAutoConnect() {
    state = state.copyWith(autoConnect: !state.autoConnect);
  }

  void toggleAutoUpload() {
    state = state.copyWith(autoUpload: !state.autoUpload);
  }

  void toggleAutoFaceRecg() {
    state = state.copyWith(autoFaceRecg: !state.autoFaceRecg);
  }
}
