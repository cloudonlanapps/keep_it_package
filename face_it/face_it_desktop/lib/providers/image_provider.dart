/* import 'dart:async';

import 'package:collection/collection.dart';
import 'package:face_it_desktop/models/session_candidate.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@immutable
class SessionCandidates {
  const SessionCandidates({required this.items, this.activePath});
  final List<SessionCandidate> items;
  final String? activePath;

  SessionCandidates copyWith({
    List<SessionCandidate>? items,
    ValueGetter<String?>? activePath,
  }) {
    return SessionCandidates(
      items: items ?? this.items,
      activePath: activePath != null ? activePath.call() : this.activePath,
    );
  }

  @override
  bool operator ==(covariant SessionCandidates other) {
    if (identical(this, other)) return true;
    final listEquals = const DeepCollectionEquality().equals;

    return listEquals(other.items, items) && other.activePath == activePath;
  }

  @override
  int get hashCode => items.hashCode ^ activePath.hashCode;

  SessionCandidate? get activeMedia =>
      items.where((item) => item.path == activePath).firstOrNull;
}

class AvailableMediaNotifier extends AsyncNotifier<SessionCandidates> {
  @override
  FutureOr<SessionCandidates> build() {
    return const SessionCandidates(items: []);
  }

  Future<void> addImages(List<SessionCandidate> images) async {
    final uniqueImages = images.where(
      (e) => !state.value!.items.map((c) => c.path).contains(e.path),
    );
    state = AsyncData(
      state.value!.copyWith(items: [...state.value!.items, ...uniqueImages]),
    );
  }

  Future<void> removeImagesByPath(List<String> pathsToRemove) async {
    state = AsyncData(
      state.value!.copyWith(
        items: state.value!.items.where((item) {
          return !pathsToRemove.contains(item.path);
        }).toList(),
      ),
    );
  }

  Future<void> clear() async {
    state = const AsyncData(SessionCandidates(items: []));
  }

  SessionCandidate? get activeMedia => state.value!.activeMedia;
  set activeMedia(SessionCandidate? value) {
    if (value == null) {
      state = AsyncData(state.value!.copyWith(activePath: () => null));
    } else {
      final path = value.path;
      final item = state.value!.items
          .where((item) => item.path == path)
          .firstOrNull;
      if (item != null) {
        state = AsyncData(state.value!.copyWith(activePath: () => path));
      }
    }
  }
}

final availableMediaProvider =
    AsyncNotifierProvider<AvailableMediaNotifier, SessionCandidates>(
      AvailableMediaNotifier.new,
    );
 */
