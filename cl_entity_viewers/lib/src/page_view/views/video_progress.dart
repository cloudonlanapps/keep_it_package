import 'dart:math';

import 'package:cl_extensions/cl_extensions.dart' show UtilExtensionOnDuration;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'package:video_player/video_player.dart';

import '../models/cl_icons.dart';
import '../builders/get_uri_play_status.dart';
import '../providers/ui_state.dart';
import 'on_rotate.dart';

double durationToDouble(Duration duration) => duration.inSeconds.toDouble();

Duration doubleToDuration(double position) =>
    Duration(minutes: position ~/ 60, seconds: (position % 60).truncate());

extension ExtVideoPlayerValue on VideoPlayerValue {
  double get bufferedInSeconds => min(
    buffered.isEmpty ? 0.0 : buffered.last.end.inSeconds.toDouble(),
    duration.inSeconds.toDouble(),
  );
  double get durationInSeconds => durationToDouble(duration);
  double get positionInSeconds => durationToDouble(position);

  String playTimeString(double? seekValue) {
    final isLive = durationToDouble(duration) > 10 * 60 * 60;
    final currentPosition = seekValue == null
        ? position
        : doubleToDuration(seekValue);

    if (isLive) {
      if (isCompleted) {
        return '__ / __';
      }
      return '${currentPosition.timestamp} / __';
    } else {
      return '${currentPosition.timestamp} / ${duration.timestamp}';
    }
  }
}

class VideoProgress extends ConsumerStatefulWidget {
  const VideoProgress({required this.uri, super.key});

  final Uri uri;

  @override
  ConsumerState<VideoProgress> createState() => _VideoProgressState();
}

class _VideoProgressState extends ConsumerState<VideoProgress> {
  double? seekValue;
  @override
  Widget build(BuildContext context) {
    final showBuffering = !widget.uri.isScheme('file');
    return GetUriPlayStatus(
      uri: widget.uri,
      builder: ([playerControls, playStatus]) {
        if (playerControls == null || playStatus == null) {
          return const SizedBox.shrink();
        }
        return LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              spacing: 4,
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: OnRotateLeft(uri: widget.uri),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: MenuBackground2(
                    child: Row(
                      children: [
                        Flexible(
                          flex: 3,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 16),
                            child: Material(
                              color: Colors.transparent,
                              child: Stack(
                                children: [
                                  // required only for network
                                  if (showBuffering)
                                    SliderTheme(
                                      data: SliderTheme.of(context).copyWith(
                                        overlayShape: const SmallOverlayShape(),
                                        trackShape: CustomTrackShape(),
                                        trackHeight: 2,
                                        thumbShape:
                                            SliderComponentShape.noThumb,
                                        disabledActiveTrackColor:
                                            playerUIPreferences
                                                .activeBufferColor,
                                        disabledInactiveTrackColor:
                                            playerUIPreferences.inactiveColor,
                                      ),
                                      child: Slider(
                                        max: playStatus.durationInSeconds,
                                        value: playStatus.bufferedInSeconds,
                                        onChanged: null,
                                      ),
                                    ),

                                  SliderTheme(
                                    data: SliderTheme.of(context).copyWith(
                                      overlayShape: const SmallOverlayShape(),
                                      trackHeight: 2,
                                      trackShape: CustomTrackShape(),
                                      thumbShape: const RoundSliderThumbShape(
                                        enabledThumbRadius: 6,
                                        pressedElevation: 2,
                                      ),
                                      activeTrackColor:
                                          playerUIPreferences.foregroundColor,
                                      inactiveTrackColor: showBuffering
                                          ? const Color.fromARGB(0, 0, 0, 0)
                                          : playerUIPreferences.inactiveColor,
                                      thumbColor: Colors.red,
                                    ),
                                    child: Slider(
                                      max: playStatus.durationInSeconds,
                                      value: playStatus.positionInSeconds,
                                      onChanged: (double value) {
                                        setState(() => seekValue = value);
                                        ref
                                            .read(
                                              mediaViewerUIStateProvider
                                                  .notifier,
                                            )
                                            .showPlayerMenu();
                                      },
                                      onChangeEnd: (double value) {
                                        setState(() => seekValue = null);
                                        playerControls.seekTo(
                                          doubleToDuration(value),
                                        );
                                        ref
                                            .read(
                                              mediaViewerUIStateProvider
                                                  .notifier,
                                            )
                                            .showPlayerMenu();
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: FittedBox(
                            child: Text(
                              playStatus.playTimeString(seekValue),
                              style: ShadTheme.of(context).textTheme.muted
                                  .copyWith(
                                    fontSize: 10,
                                    color: playerUIPreferences.foregroundColor,
                                  ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class CustomTrackShape extends RoundedRectSliderTrackShape {
  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    Offset offset = Offset.zero,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final trackHeight = sliderTheme.trackHeight ?? 4;
    final trackLeft = offset.dx + 12; // horizontal padding
    final trackTop = offset.dy + (parentBox.size.height - trackHeight) / 2;
    final trackWidth = parentBox.size.width - 24; // horizontal padding * 2
    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }
}

class SmallOverlayShape extends SliderComponentShape {
  const SmallOverlayShape({this.size = 12});
  final double size;

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size.square(size);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final paint = Paint()
      ..color =
          sliderTheme.overlayColor?.withValues(alpha: 255 * 0.2) ??
          Colors.grey.withValues(alpha: 255 * 0.2);
    context.canvas.drawCircle(center, size / 2, paint);
  }
}

class MenuBackground2 extends ConsumerWidget {
  const MenuBackground2({required this.child, super.key});
  final Widget child;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(24),
      ),
      // margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: child,
    );
  }
}
