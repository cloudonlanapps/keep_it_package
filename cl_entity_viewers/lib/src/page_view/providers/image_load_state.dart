import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Tracks whether an image has been loaded for a specific entity.
/// Key is the entity ID.
class ImageLoadStateNotifier extends StateNotifier<Map<int, bool>> {
  ImageLoadStateNotifier() : super({});

  /// Mark an image as loaded for the given entity ID.
  void setLoaded(int entityId) {
    if (state[entityId] != true) {
      state = {...state, entityId: true};
    }
  }

  /// Check if an image is loaded for the given entity ID.
  bool isLoaded(int entityId) => state[entityId] ?? false;

  /// Clear loading state (e.g., when navigating away).
  void clear(int entityId) {
    if (state.containsKey(entityId)) {
      state = Map.from(state)..remove(entityId);
    }
  }

  /// Clear all loading states.
  void clearAll() {
    state = {};
  }
}

final imageLoadStateProvider =
    StateNotifierProvider<ImageLoadStateNotifier, Map<int, bool>>(
  (ref) => ImageLoadStateNotifier(),
);
