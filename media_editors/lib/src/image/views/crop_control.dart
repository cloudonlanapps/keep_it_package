import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../models/aspect_ratio.dart' as aratio;

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
    final theme = ShadTheme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.background, // Color for the circular container
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
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Crop',
                          style: theme.textTheme.h3,
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
                              ShadButton.ghost(
                                onPressed: aspectRatio == null
                                    ? null
                                    : () => onChangeAspectRatio(null),
                                child: const Text('Free form'),
                              ),
                            ],
                          ),
                        ),
                        for (final ratio
                            in const aratio.SupportedAspectRatiosDefault()
                                .aspectRatios)
                          Padding(
                            padding: const EdgeInsets.only(
                              right: 16,
                              top: 4,
                              bottom: 4,
                            ),
                            child: Column(
                              children: [
                                ShadButton.ghost(
                                  onPressed: aspectRatio?.ratio == ratio.ratio
                                      ? null
                                      : () {
                                          onChangeAspectRatio(
                                            ratio.copyWith(
                                              isLandscape:
                                                  aspectRatio?.isLandscape,
                                            ),
                                          );
                                        },
                                  child: Text(ratio.title),
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
