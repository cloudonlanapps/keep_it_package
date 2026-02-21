import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/app_preference_provider.dart';

/// Immutable class encapsulating face overlay settings actions.
@immutable
class FaceOverlayActions {
  const FaceOverlayActions({
    required this.toggleBoxes,
    required this.toggleLandmarks,
    required this.setShowBoxes,
    required this.setShowLandmarks,
    required this.enableAll,
    required this.disableAll,
  });

  final void Function() toggleBoxes;
  final void Function() toggleLandmarks;
  final void Function({required bool value}) setShowBoxes;
  final void Function({required bool value}) setShowLandmarks;
  final void Function() enableAll;
  final void Function() disableAll;
}

/// Builder widget that watches face overlay settings and exposes actions.
///
/// This builder decouples views from direct provider access by providing
/// face overlay settings and actions through callback parameters.
///
/// Example usage:
/// ```dart
/// GetFaceOverlaySettings(
///   builder: (settings, actions) {
///     return Column(
///       children: [
///         SwitchListTile(
///           title: Text('Show Boxes'),
///           value: settings.showBoxes,
///           onChanged: actions.setShowBoxes,
///         ),
///         SwitchListTile(
///           title: Text('Show Landmarks'),
///           value: settings.showLandmarks,
///           onChanged: actions.setShowLandmarks,
///         ),
///       ],
///     );
///   },
/// )
/// ```
class GetFaceOverlaySettings extends ConsumerWidget {
  const GetFaceOverlaySettings({
    required this.builder,
    super.key,
  });

  final Widget Function(FaceOverlaySettings, FaceOverlayActions) builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings =
        ref.watch(appPreferenceProvider.select((e) => e.faceOverlay));
    final actions = FaceOverlayActions(
      toggleBoxes: () =>
          ref.read(appPreferenceProvider.notifier).toggleFaceBoxes(),
      toggleLandmarks: () =>
          ref.read(appPreferenceProvider.notifier).toggleFaceLandmarks(),
      setShowBoxes: ({required value}) =>
          ref.read(appPreferenceProvider.notifier).showFaceBoxes = value,
      setShowLandmarks: ({required value}) =>
          ref.read(appPreferenceProvider.notifier).showFaceLandmarks = value,
      enableAll: () =>
          ref.read(appPreferenceProvider.notifier).enableAllFaceOverlays(),
      disableAll: () =>
          ref.read(appPreferenceProvider.notifier).disableAllFaceOverlays(),
    );
    return builder(settings, actions);
  }
}
