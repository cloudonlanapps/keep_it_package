import 'package:flutter/material.dart';

import '../models/cl_scale_type.dart';
import '../theme/models/cl_icons.dart';
import 'cl_text.dart';
import 'svg_icon.dart';

class _CLIcon extends StatelessWidget {
  const _CLIcon(
    this.iconData, {
    required this.text,
    required this.scaleType,
    super.key,
    this.color,
  });
  final Object? iconData;
  final String? text;
  final CLScaleType scaleType;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    if (text == null) {
      return switch (iconData) {
        (final IconData iconData) => Icon(
          iconData,
          color: color,
          size: scaleType.iconSize,
        ),
        (final SvgIcons svgIcons) => SvgIcon(
          svgIcons,
          color: color,
          size: scaleType.iconSize,
        ),
        _ => throw Exception('Only IconData or compatible types are supported'),
      };
    }
    return switch (iconData) {
      (final IconData iconData) => Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          iconData.iconFormatted(
            color: color ?? Theme.of(context).textTheme.bodyLarge?.color,
            size: scaleType.iconSize,
          ),
          switch (scaleType) {
            CLScaleType.veryLarge => CLText.veryLarge,
            CLScaleType.large => CLText.large,
            CLScaleType.standard => CLText.standard,
            CLScaleType.small => CLText.small,
            CLScaleType.verySmall => CLText.verySmall,
            CLScaleType.tiny => CLText.tiny,
          }(text!, color: color),
        ],
      ),
      _ => throw Exception('only IonData or SVGIconSupported'),
    };
  }
}

class CLIcon extends _CLIcon {
  const CLIcon.veryLarge(super.iconData, {super.key, super.color})
    : super(text: null, scaleType: CLScaleType.veryLarge);
  const CLIcon.large(super.iconData, {super.key, super.color})
    : super(text: null, scaleType: CLScaleType.large);

  const CLIcon.standard(super.iconData, {super.key, super.color})
    : super(text: null, scaleType: CLScaleType.standard);
  const CLIcon.small(super.iconData, {super.key, super.color})
    : super(text: null, scaleType: CLScaleType.small);
  const CLIcon.verySmall(super.iconData, {super.key, super.color})
    : super(text: null, scaleType: CLScaleType.verySmall);
  const CLIcon.tiny(super.iconData, {super.key, super.color})
    : super(text: null, scaleType: CLScaleType.tiny);
}

class CLIconLabelled extends _CLIcon {
  const CLIconLabelled.veryLarge(
    super.iconData,
    String text, {
    super.key,
    super.color,
  }) : super(text: text, scaleType: CLScaleType.veryLarge);
  const CLIconLabelled.large(
    super.iconData,
    String text, {
    super.key,
    super.color,
  }) : super(text: text, scaleType: CLScaleType.large);
  const CLIconLabelled.standard(
    super.iconData,
    String text, {
    super.key,
    super.color,
  }) : super(text: text, scaleType: CLScaleType.standard);
  const CLIconLabelled.small(
    super.iconData,
    String text, {
    super.key,
    super.color,
  }) : super(text: text, scaleType: CLScaleType.small);
  const CLIconLabelled.verySmall(
    super.iconData,
    String text, {
    super.key,
    super.color,
  }) : super(text: text, scaleType: CLScaleType.verySmall);
  const CLIconLabelled.tiny(
    super.iconData,
    String text, {
    super.key,
    super.color,
  }) : super(text: text, scaleType: CLScaleType.tiny);
}
