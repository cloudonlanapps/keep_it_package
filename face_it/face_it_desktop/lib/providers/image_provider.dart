import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

class ImageListNotifier extends AsyncNotifier<List<String>> {
  @override
  FutureOr<List<String>> build() {
    return [];
  }

  Future<void> addImages(List<String> images) async {
    state = AsyncData([...state.value!, ...images]);
  }

  Future<void> removeImages(List<String> images) async {
    state = AsyncData(state.value!.where((e) => !images.contains(e)).toList());
  }

  Future<void> removeAll() async {
    state = AsyncData(<String>[]);
  }
}
