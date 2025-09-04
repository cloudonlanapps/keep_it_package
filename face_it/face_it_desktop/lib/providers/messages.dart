import 'package:flutter_riverpod/flutter_riverpod.dart';

extension ExtRemoveOld<T> on List<T> {
  List<T> removeOld() => length <= 100 ? this : sublist(length - 100);
}

class MessagesNotifier extends StateNotifier<List<String>> {
  MessagesNotifier() : super(const []);

  void addMessage(String msg) {
    final now = DateTime.now().toIso8601String();

    state = [...state.removeOld(), '[$now] $msg'];
  }
}

final messagesProvider = StateNotifierProvider<MessagesNotifier, List<String>>((
  ref,
) {
  return MessagesNotifier();
});
