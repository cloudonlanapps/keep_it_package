import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';

import '../models/aspect_ratio.dart' as aratio;

import '../models/aspect_ratio.dart';
import 'crop_orientation_control.dart';

class CropperControls extends StatelessWidget {
  const CropperControls({
    required this.rotateAngle,
    required this.aspectRatio,
    required this.onChangeAspectRatio,
    super.key,
    this.saveWidget,
  });

  final double rotateAngle;
  final aratio.AspectRatio? aspectRatio;
  final void Function(aratio.AspectRatio? aspectRatio) onChangeAspectRatio;
  final Widget? saveWidget;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: CLTheme.of(context)
            .colors
            .wizardButtonForegroundColor, // Color for the circular container
      ),
      child: Row(
        children: [
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: CLText.large(
                          'Crop',
                        ),
                      ),
                      Align(
                        child: CropOrientation(
                          rotateAngle: rotateAngle,
                          aspectRatio: aspectRatio,
                          onToggleCropOrientation: () {
                            onChangeAspectRatio(
                              aspectRatio?.copyWith(
                                isLandscape:
                                    !(aspectRatio?.isLandscape ?? false),
                              ),
                            );
                          },
                        ),
                      ),
                      Container(),
                    ].map((e) => Expanded(child: e)).toList(),
                  ),
                ),
                Container(
                  // height: 80,
                  alignment: Alignment.center,

                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(
                            right: 16,
                            top: 4,
                            bottom: 4,
                          ),
                          child: Column(
                            children: [
                              CLButtonText.standard(
                                'Free form',
                                disabledColor: CLTheme.of(context)
                                    .colors
                                    .disabledIconColor,
                                color: CLTheme.of(context).colors.iconColor,
                                onTap: aspectRatio == null
                                    ? null
                                    : () => onChangeAspectRatio(null),
                              ),
                            ],
                          ),
                        ),
                        for (final ratio in const SupportedAspectRatiosDefault()
                            .aspectRatios)
                          Padding(
                            padding: const EdgeInsets.only(
                              right: 16,
                              top: 4,
                              bottom: 4,
                            ),
                            child: Column(
                              children: [
                                CLButtonText.standard(
                                  ratio.title,
                                  disabledColor: CLTheme.of(context)
                                      .colors
                                      .disabledIconColor,
                                  color: CLTheme.of(context).colors.iconColor,
                                  onTap: aspectRatio?.ratio == ratio.ratio
                                      ? null
                                      : () {
                                          onChangeAspectRatio(
                                            ratio.copyWith(
                                              isLandscape:
                                                  aspectRatio?.isLandscape,
                                            ),
                                          );
                                        },
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            width: 4,
            child: DecoratedBox(decoration: BoxDecoration(color: Colors.white)),
          ),
          ?saveWidget,
        ],
      ),
    );
  }
}
