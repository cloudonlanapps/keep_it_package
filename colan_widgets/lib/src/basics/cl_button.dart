import 'package:colan_widgets/src/basics/cl_icon.dart';
import 'package:flutter/material.dart';

import '../models/cl_scale_type.dart';

class _CLButton extends StatelessWidget {
  const _CLButton({
    required this.iconData,
    required this.label,
    required this.scaleType,
    super.key,
    this.color,
    Color? disabledColor,
    this.onTap,
    this.boxDecoration,
  }) : disabledColor = disabledColor ?? color;
  final Object? iconData;
  final String? label;
  final Color? color;
  final Color? disabledColor;
  final CLScaleType scaleType;
  final void Function()? onTap;
  final BoxDecoration? boxDecoration;

  Color? get color_ => onTap == null ? disabledColor : color;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ButtonBackground(
        boxDecoration: boxDecoration,
        child: switch (label) {
          null => switch (scaleType) {
            CLScaleType.veryLarge => CLIcon.veryLarge,
            CLScaleType.large => CLIcon.large,
            CLScaleType.standard => CLIcon.standard,
            CLScaleType.small => CLIcon.small,
            CLScaleType.verySmall => CLIcon.verySmall,
            CLScaleType.tiny => CLIcon.tiny,
          }(iconData, color: color_),
          _ => switch (scaleType) {
            CLScaleType.veryLarge => CLIconLabelled.veryLarge,
            CLScaleType.large => CLIconLabelled.large,
            CLScaleType.standard => CLIconLabelled.standard,
            CLScaleType.small => CLIconLabelled.small,
            CLScaleType.verySmall => CLIconLabelled.verySmall,
            CLScaleType.tiny => CLIconLabelled.tiny,
          }(iconData, label!, color: color_),
        },
      ),
    );
  }
}

class ButtonBackground extends StatelessWidget {
  const ButtonBackground({
    required this.child,
    super.key,
    this.boxDecoration,
  });
  final Widget child;
  final BoxDecoration? boxDecoration;

  @override
  Widget build(BuildContext context) {
    if (boxDecoration == null) {
      return child;
    }
    return Container(
      decoration: boxDecoration,
      child: Center(child: child),
    );
  }
}

class CLButtonText extends _CLButton {
  const CLButtonText.veryLarge(
    String label, {
    super.key,
    super.color,
    super.disabledColor,
    super.onTap,
    super.boxDecoration,
  }) : super(label: label, iconData: null, scaleType: CLScaleType.veryLarge);
  const CLButtonText.large(
    String label, {
    super.key,
    super.color,
    super.disabledColor,
    super.onTap,
    super.boxDecoration,
  }) : super(label: label, iconData: null, scaleType: CLScaleType.large);
  const CLButtonText.standard(
    String label, {
    super.key,
    super.color,
    super.disabledColor,
    super.onTap,
    super.boxDecoration,
  }) : super(label: label, iconData: null, scaleType: CLScaleType.standard);
  const CLButtonText.small(
    String label, {
    super.key,
    super.color,
    super.disabledColor,
    super.onTap,
  }) : super(label: label, iconData: null, scaleType: CLScaleType.small);
  const CLButtonText.verySmall(
    String label, {
    super.key,
    super.color,
    super.disabledColor,
    super.onTap,
    super.boxDecoration,
  }) : super(label: label, iconData: null, scaleType: CLScaleType.verySmall);
  const CLButtonText.tiny(
    String label, {
    super.key,
    super.color,
    super.disabledColor,
    super.onTap,
    super.boxDecoration,
  }) : super(label: label, iconData: null, scaleType: CLScaleType.tiny);
}

class CLButtonIcon extends _CLButton {
  const CLButtonIcon.veryLarge(
    dynamic iconData, {
    super.key,
    super.color,
    super.disabledColor,
    super.onTap,
  }) : super(label: null, iconData: iconData, scaleType: CLScaleType.veryLarge);
  const CLButtonIcon.large(
    dynamic iconData, {
    super.key,
    super.color,
    super.disabledColor,
    super.onTap,
  }) : super(label: null, iconData: iconData, scaleType: CLScaleType.large);
  const CLButtonIcon.standard(
    dynamic iconData, {
    super.key,
    super.color,
    super.disabledColor,
    super.onTap,
  }) : super(label: null, iconData: iconData, scaleType: CLScaleType.standard);
  const CLButtonIcon.small(
    dynamic iconData, {
    super.key,
    super.color,
    super.disabledColor,
    super.onTap,
  }) : super(label: null, iconData: iconData, scaleType: CLScaleType.small);
  const CLButtonIcon.verySmall(
    dynamic iconData, {
    super.key,
    super.color,
    super.disabledColor,
    super.onTap,
  }) : super(label: null, iconData: iconData, scaleType: CLScaleType.verySmall);
  const CLButtonIcon.tiny(
    dynamic iconData, {
    super.key,
    super.color,
    super.disabledColor,
    super.onTap,
  }) : super(label: null, iconData: iconData, scaleType: CLScaleType.tiny);
}

class CLButtonIconLabelled extends _CLButton {
  const CLButtonIconLabelled.veryLarge(
    dynamic iconData,
    String label, {
    super.key,
    super.color,
    super.disabledColor,
    super.onTap,
  }) : super(
         label: label,
         iconData: iconData,
         scaleType: CLScaleType.veryLarge,
       );
  const CLButtonIconLabelled.large(
    dynamic iconData,
    String label, {
    super.key,
    super.color,
    super.disabledColor,
    super.onTap,
  }) : super(label: label, iconData: iconData, scaleType: CLScaleType.large);
  const CLButtonIconLabelled.standard(
    dynamic iconData,
    String label, {
    super.key,
    super.color,
    super.disabledColor,
    super.onTap,
  }) : super(label: label, iconData: iconData, scaleType: CLScaleType.standard);
  const CLButtonIconLabelled.small(
    dynamic iconData,
    String label, {
    super.key,
    super.color,
    super.disabledColor,
    super.onTap,
  }) : super(label: label, iconData: iconData, scaleType: CLScaleType.small);
  const CLButtonIconLabelled.verySmall(
    dynamic iconData,
    String label, {
    super.key,
    super.color,
    super.disabledColor,
    super.onTap,
  }) : super(
         label: label,
         iconData: iconData,
         scaleType: CLScaleType.verySmall,
       );
  const CLButtonIconLabelled.tiny(
    dynamic iconData,
    String label, {
    super.key,
    super.color,
    super.disabledColor,
    super.onTap,
  }) : super(label: label, iconData: iconData, scaleType: CLScaleType.tiny);
}

class CLButtonElevatedText extends _CLButton {
  const CLButtonElevatedText.veryLarge(
    String label, {
    required BoxDecoration boxDecoration,
    super.key,
    super.color,
    super.disabledColor,
    super.onTap,
  }) : super(
         label: label,
         iconData: null,
         scaleType: CLScaleType.veryLarge,
         boxDecoration: boxDecoration,
       );
  const CLButtonElevatedText.large(
    String label, {
    required BoxDecoration boxDecoration,
    super.key,
    super.color,
    super.disabledColor,
    super.onTap,
  }) : super(
         label: label,
         iconData: null,
         scaleType: CLScaleType.large,
         boxDecoration: boxDecoration,
       );
  const CLButtonElevatedText.standard(
    String label, {
    required BoxDecoration boxDecoration,
    super.key,
    super.color,
    super.disabledColor,
    super.onTap,
  }) : super(
         label: label,
         iconData: null,
         scaleType: CLScaleType.standard,
         boxDecoration: boxDecoration,
       );
  const CLButtonElevatedText.small(
    String label, {
    required BoxDecoration boxDecoration,
    super.key,
    super.color,
    super.disabledColor,
    super.onTap,
  }) : super(
         label: label,
         iconData: null,
         scaleType: CLScaleType.small,
         boxDecoration: boxDecoration,
       );
  const CLButtonElevatedText.verySmall(
    String label, {
    required BoxDecoration boxDecoration,
    super.key,
    super.color,
    super.disabledColor,
    super.onTap,
  }) : super(
         label: label,
         iconData: null,
         scaleType: CLScaleType.verySmall,
         boxDecoration: boxDecoration,
       );
  const CLButtonElevatedText.tiny(
    String label, {
    required BoxDecoration boxDecoration,
    super.key,
    super.color,
    super.disabledColor,
    super.onTap,
  }) : super(
         label: label,
         iconData: null,
         scaleType: CLScaleType.tiny,
         boxDecoration: boxDecoration,
       );
}

class _CLButtonSquereElevated extends StatelessWidget {
  const _CLButtonSquereElevated({
    required this.child,
    required this.scaleType,
    super.key,
    this.onTap,
  });
  final Widget child;
  final void Function()? onTap;
  final CLScaleType scaleType;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: SizedBox(
        width: scaleType.fontSize * 8,
        height: scaleType.fontSize * 8,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: AspectRatio(
              aspectRatio: 1,
              child: Card(
                elevation: 12,
                shape: const ContinuousRectangleBorder(),
                margin: EdgeInsets.zero,
                child: InkWell(
                  onTap: onTap,
                  child: Align(
                    child: child,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CLButtonSquereElevated extends _CLButtonSquereElevated {
  const CLButtonSquereElevated.veryLarge({
    required super.child,
    super.key,
    super.onTap,
  }) : super(scaleType: CLScaleType.veryLarge);
  const CLButtonSquereElevated.large({
    required super.child,
    super.key,
    super.onTap,
  }) : super(scaleType: CLScaleType.large);
  const CLButtonSquereElevated.standard({
    required super.child,
    super.key,
    super.onTap,
  }) : super(scaleType: CLScaleType.standard);
  const CLButtonSquereElevated.small({
    required super.child,
    super.key,
    super.onTap,
  }) : super(scaleType: CLScaleType.small);
  const CLButtonSquereElevated.verySmall({
    required super.child,
    super.key,
    super.onTap,
  }) : super(scaleType: CLScaleType.verySmall);
  const CLButtonSquereElevated.tiny({
    required super.child,
    super.key,
    super.onTap,
  }) : super(scaleType: CLScaleType.tiny);
}
