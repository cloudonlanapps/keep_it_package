/* import 'package:flutter_riverpod/flutter_riverpod.dart';

extension ExtRemoveOld<T> on List<T> {
  List<T> removeOld() => length <= 100 ? this : sublist(length - 100);
}

class SocketMessagesNotifier extends StateNotifier<List<String>> {
  SocketMessagesNotifier() : super(const []);

  void addMessage(String msg) {
    final now = DateTime.now().toIso8601String();

    state = [...state.removeOld(), '[$now] $msg'];
  }

  void clear() {
    state = [];
  }
}

final socketMessagesProvider =
    StateNotifierProvider<SocketMessagesNotifier, List<String>>((ref) {
      return SocketMessagesNotifier();
    });
 */
