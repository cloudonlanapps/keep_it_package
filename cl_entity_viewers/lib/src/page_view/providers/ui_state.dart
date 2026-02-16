import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cl_basic_types/viewer_types.dart';

@immutable
class MediaViewerUIState {
  const MediaViewerUIState({
    this.showMenu = false,
    this.showPlayerMenu = false,
    this.entities = const ViewerEntities([]),
    this.currentIndex = 0,
  });
  final bool showMenu;
  final bool showPlayerMenu;

  final ViewerEntities entities;
  final int currentIndex;

  MediaViewerUIState copyWith({
    bool? showMenu,
    bool? showPlayerMenu,
    Color? iconColor,
    ViewerEntities? entities,
    int? currentIndex,
  }) {
    return MediaViewerUIState(
      showMenu: showMenu ?? this.showMenu,
      showPlayerMenu: showPlayerMenu ?? this.showPlayerMenu,
      entities: entities ?? this.entities,
      currentIndex: currentIndex ?? this.currentIndex,
    );
  }

  @override
  bool operator ==(covariant MediaViewerUIState other) {
    if (identical(this, other)) return true;
    final listEquals = const DeepCollectionEquality().equals;

    return other.showMenu == showMenu &&
        other.showPlayerMenu == showPlayerMenu &&
        listEquals(other.entities, entities) &&
        other.currentIndex == currentIndex;
  }

  @override
  int get hashCode {
    return showMenu.hashCode ^
        showPlayerMenu.hashCode ^
        entities.hashCode ^
        currentIndex.hashCode;
  }

  @override
  String toString() {
    return 'UIState(showMenu: $showMenu, showPlayerMenu: $showPlayerMenu, entities: $entities, currentIndex: $currentIndex)';
  }

  ViewerEntity get currentItem => entities.entities[currentIndex];

  int get length => entities.length;
}

class MediaViewerUIStateNotifier extends StateNotifier<MediaViewerUIState> {
  MediaViewerUIStateNotifier([MediaViewerUIState? mediaViewerUIState])
      : super(mediaViewerUIState ?? const MediaViewerUIState());
  Timer? disableControls;
  final Duration? defaultTimeOut = const Duration(seconds: 3);
  //final Duration? defaultTimeOut = null;

  void setupTimer([Duration? Function()? getTimeout]) {
    disableControls?.cancel();
    final Duration? timeout;

    if (getTimeout != null) {
      timeout = getTimeout();
    } else {
      timeout = defaultTimeOut;
    }
    if (timeout != null) {
      disableControls = Timer(
        timeout,
        () {
          state = state.copyWith(showPlayerMenu: false);
        },
      );
    }
  }

  void notify(MediaViewerUIState value, [Duration? Function()? timeout]) {
    setupTimer(timeout);
    state = value;
  }

  void showMenu([Duration? Function()? timeout]) =>
      notify(state.copyWith(showMenu: true, showPlayerMenu: true));

  void hideMenu([Duration? Function()? timeout]) =>
      notify(state.copyWith(showMenu: false, showPlayerMenu: true));

  void toggleMenu([Duration? Function()? timeout]) =>
      notify(state.copyWith(showMenu: !state.showMenu, showPlayerMenu: true));

  void showPlayerMenu([Duration? Function()? timeout]) =>
      notify(state.copyWith(showPlayerMenu: true));

  set currIndex(int value) => notify(state.copyWith(currentIndex: value));
  int get currIndex => state.currentIndex;

  set entities(ViewerEntities entities) =>
      notify(state.copyWith(entities: entities));
  ViewerEntities get entities => state.entities;

  @override
  void dispose() {
    disableControls?.cancel();
    super.dispose();
  }
}

final mediaViewerUIStateProvider =
    StateNotifierProvider<MediaViewerUIStateNotifier, MediaViewerUIState>(
        (ref) {
  return MediaViewerUIStateNotifier();
});
