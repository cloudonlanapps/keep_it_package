// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';

import 'package:collection/collection.dart';
import 'package:face_it_desktop/models/media_descriptor.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@immutable
class AvailableMedia {
  const AvailableMedia({required this.items, this.activePath});
  final List<MediaDescriptor> items;
  final String? activePath;

  AvailableMedia copyWith({
    List<MediaDescriptor>? items,
    ValueGetter<String?>? activePath,
  }) {
    return AvailableMedia(
      items: items ?? this.items,
      activePath: activePath != null ? activePath.call() : this.activePath,
    );
  }

  @override
  bool operator ==(covariant AvailableMedia other) {
    if (identical(this, other)) return true;
    final listEquals = const DeepCollectionEquality().equals;

    return listEquals(other.items, items) && other.activePath == activePath;
  }

  @override
  int get hashCode => items.hashCode ^ activePath.hashCode;

  MediaDescriptor? get activeMedia =>
      items.where((item) => item.path == activePath).firstOrNull;
}

class AvailableMediaNotifier extends AsyncNotifier<AvailableMedia> {
  @override
  FutureOr<AvailableMedia> build() {
    return AvailableMedia(items: const []);
  }

  Future<void> addImages(List<MediaDescriptor> images) async {
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
    state = AsyncData(AvailableMedia(items: const []));
  }

  MediaDescriptor? get activeMedia => state.value!.activeMedia;
  set activeMedia(MediaDescriptor? value) {
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
    AsyncNotifierProvider<AvailableMediaNotifier, AvailableMedia>(
      AvailableMediaNotifier.new,
    );
