import 'package:face_it_desktop/providers/face_box_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/bbox.dart';
import '../../models/face.dart';
//import '../face_view/known_face_popover.dart';
import '../face_view/unknown_face_popover.dart';

class DrawFace extends Positioned {
  DrawFace.positioned({required DetectedFace face, super.key})
    : super(
        child: SizedBox(
          width: face.bbox.width,
          height: face.bbox.height + 100,

          child: UnknownFacePopOver(face: face),
        ),
        left: face.bbox.xmin,
        top: face.bbox.ymin - 100,
      );
}

class DrawBBox extends ConsumerWidget {
  const DrawBBox({required this.bbox, super.key});

  final BBox bbox;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = ref.watch(faceBoxPreferenceProvider.select((e) => e.color));
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: bbox.xmax - bbox.xmin,
          height: 100,
          padding: const EdgeInsets.all(8),
          alignment: Alignment.bottomCenter,
          child: FittedBox(
            child: GradientBackgroundText(
              text: 'Amizhthini',
              gradient: LinearGradient(
                colors: [color.withAlpha(0x80), color, color.withAlpha(0x80)],
              ),
              style: const TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        Container(
          width: bbox.xmax - bbox.xmin,
          height: bbox.ymax - bbox.ymin,
          decoration: BoxDecoration(
            border: Border.all(width: 10, color: color),
          ),
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
