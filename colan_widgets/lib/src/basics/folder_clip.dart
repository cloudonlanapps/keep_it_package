import 'package:flutter/material.dart';

class FolderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path()
      ..moveTo(0, size.height * 0.2)
      ..lineTo(0, size.height * 0.1)
      ..quadraticBezierTo(0, 0, size.width * 0.1, 0)
      ..lineTo(size.width * 0.3, 0)
      ..lineTo(size.width * 0.4, size.height * 0.1)
      ..lineTo(size.width * 0.9, size.height * 0.1)
      ..quadraticBezierTo(
        size.width,
        size.height * 0.1,
        size.width,
        size.height * 0.2,
      )
      ..lineTo(size.width, size.height * 0.9)
      ..quadraticBezierTo(
        size.width,
        size.height,
        size.width * 0.9,
        size.height,
      )
      ..lineTo(size.width * 0.1, size.height)
      ..quadraticBezierTo(0, size.height, 0, size.height * 0.9)
      ..close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class FolderPainter extends CustomPainter {
  FolderPainter({
    this.borderColor = Colors.black54,
    this.strokeWidth = 1.0,
  });
  final Color borderColor;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final path = Path()
      // Same path as clipper
      ..moveTo(0, size.height * 0.2)
      ..lineTo(0, size.height * 0.1)
      ..quadraticBezierTo(0, 0, size.width * 0.1, 0)
      ..lineTo(size.width * 0.3, 0)
      ..lineTo(size.width * 0.4, size.height * 0.1)
      ..lineTo(size.width * 0.9, size.height * 0.1)
      ..quadraticBezierTo(
        size.width,
        size.height * 0.1,
        size.width,
        size.height * 0.2,
      )
      ..lineTo(size.width, size.height * 0.9)
      ..quadraticBezierTo(
        size.width,
        size.height,
        size.width * 0.9,
        size.height,
      )
      ..lineTo(size.width * 0.1, size.height)
      ..quadraticBezierTo(0, size.height, 0, size.height * 0.9)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class FolderWidget extends StatelessWidget {
  const FolderWidget({
    required this.child,
    super.key,
    this.folderColor = const Color(0xFFE6B65C),
    this.borderColor = const Color(0xFFE6B65C),
    this.borderWidth = 1.0,
    this.width = 200,
    this.height = 150,
  });
  final Widget child;
  final Color folderColor;
  final Color borderColor;
  final double borderWidth;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipPath(
          clipper: FolderClipper(),
          child: SizedBox(
            width: width,
            height: height,
            /*  decoration: BoxDecoration(
              color: folderColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ), */
            child: child,
          ),
        ),
        CustomPaint(
          painter: FolderPainter(
            borderColor: borderColor,
            strokeWidth: borderWidth,
          ),
          size: Size(width, height),
        ),
      ],
    );
  }
}
