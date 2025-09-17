import 'package:dotted_border/dotted_border.dart';
import 'package:face_it_desktop/models/face/detected_face.dart';
import 'package:face_it_desktop/providers/face_box_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/f_face.dart';

class DrawBBox extends ConsumerWidget {
  const DrawBBox({required this.faceId, super.key});
  final String faceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final face = ref
        .watch(detectedFaceProvider(faceId))
        .whenOrNull(data: (data) => data);

    if (face == null) {
      return const SizedBox.shrink();
    }
    if (face.status == FaceStatus.notFoundNotAFace) {
      return DottedBorder(
        options: const RectDottedBorderOptions(
          dashPattern: [5, 5],
          strokeWidth: 5,
        ),
        child: SizedBox(
          width: face.descriptor.bbox.width,
          height: face.descriptor.bbox.height,
        ),
      );
    }

    final color = ref.watch(faceBoxPreferenceProvider.select((e) => e.color));
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (face.status != FaceStatus.notFoundNotAFace)
          Container(
            width: face.descriptor.bbox.width,
            height: 100,
            padding: const EdgeInsets.all(8),
            alignment: Alignment.bottomCenter,
            child: FittedBox(
              child: GradientBackgroundText(
                text: face.label,
                gradient: LinearGradient(
                  colors: [color.withAlpha(0x80), color, color.withAlpha(0x80)],
                ),
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        Container(
          width: face.descriptor.bbox.width,
          height: face.descriptor.bbox.height,
          decoration: BoxDecoration(border: Border.all(width: 5, color: color)),
        ),
      ],
    );
  }
}

class GradientBackgroundText extends StatelessWidget {
  const GradientBackgroundText({
    required this.text,
    required this.gradient,
    required this.style,
    super.key,
    this.padding = EdgeInsets.zero,
    this.borderRadius,
  });
  final String text;
  final TextStyle style;
  final Gradient gradient;
  final EdgeInsetsGeometry padding;
  final BorderRadiusGeometry? borderRadius;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _GradientBackgroundTextPainter(
        text: text,
        style: style,
        gradient: gradient,
        padding: padding,
        borderRadius: borderRadius,
      ),
      child: Padding(
        padding: padding,
        child: Text(text, style: style),
      ),
    );
  }
}

class _GradientBackgroundTextPainter extends CustomPainter {
  _GradientBackgroundTextPainter({
    required this.text,
    required this.style,
    required this.gradient,
    required this.padding,
    this.borderRadius,
  });
  final String text;
  final TextStyle style;
  final Gradient gradient;
  final EdgeInsetsGeometry padding;
  final BorderRadiusGeometry? borderRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final textSpan = TextSpan(text: text, style: style);

    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    )..layout();

    // Calculate the size of the background rect, including padding
    final backgroundWidth = textPainter.size.width + padding.horizontal;
    final backgroundHeight = textPainter.size.height + padding.vertical;

    // Center the background rect within the CustomPaint widget's size
    final backgroundRect = Rect.fromLTWH(
      (size.width - backgroundWidth) / 2,
      (size.height - backgroundHeight) / 2,
      backgroundWidth,
      backgroundHeight,
    );

    // Create the shader for the paint object based on the larger rect
    final paint = Paint()..shader = gradient.createShader(backgroundRect);

    // Draw the rounded rectangle with the gradient
    if (borderRadius != null) {
      canvas.drawRRect(
        borderRadius!.resolve(TextDirection.ltr).toRRect(backgroundRect),
        paint,
      );
    } else {
      canvas.drawRect(backgroundRect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _GradientBackgroundTextPainter oldDelegate) {
    return oldDelegate.text != text ||
        oldDelegate.style != style ||
        oldDelegate.gradient != gradient ||
        oldDelegate.padding != padding ||
        oldDelegate.borderRadius != borderRadius;
  }
}
