// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';

import 'package:collection/collection.dart';
import 'package:face_it_desktop/models/media_descriptor.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@immutable
class AvailableMedia {
  const AvailableMedia({required this.items, this.currentIndex = 0});
  final List<MediaDescriptor> items;
  final int currentIndex;

  AvailableMedia copyWith({List<MediaDescriptor>? items, int? currentIndex}) {
    return AvailableMedia(
      items: items ?? this.items,
      currentIndex: currentIndex ?? this.currentIndex,
    );
  }

  @override
  bool operator ==(covariant AvailableMedia other) {
    if (identical(this, other)) return true;
    final listEquals = const DeepCollectionEquality().equals;

    return listEquals(other.items, items) && other.currentIndex == currentIndex;
  }

  @override
  int get hashCode => items.hashCode ^ currentIndex.hashCode;
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

  Future<void> removeImages(List<MediaDescriptor> images) async {
    state = AsyncData(
      state.value!.copyWith(
        items: state.value!.items.where((e) => !images.contains(e)).toList(),
      ),
    );
  }

  Future<void> clear() async {
    state = AsyncData(AvailableMedia(items: const []));
  }
}

final availableMediaProvider =
    AsyncNotifierProvider<AvailableMediaNotifier, AvailableMedia>(
      AvailableMediaNotifier.new,
    );
