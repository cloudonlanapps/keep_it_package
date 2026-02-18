import 'package:flutter/material.dart';

class OverlayWidgets extends StatelessWidget {
  factory OverlayWidgets({
    required Widget child,
    required Alignment alignment,
    double? widthFactor = 0.3,
    double? heightFactor = 0.3,
    BoxFit? fit,
    Key? key,
  }) {
    return OverlayWidgets._(
      alignment: alignment,
      widthFactor: widthFactor,
      heightFactor: heightFactor,
      key: key,
      fit: fit,
      child: child,
    );
  }
  factory OverlayWidgets.dimension({
    required Widget child,
    required Alignment alignment,
    double? sizeFactor = 0.3,
    Key? key,
    BoxFit? fit,
  }) {
    return OverlayWidgets._(
      alignment: alignment,
      widthFactor: sizeFactor,
      heightFactor: sizeFactor,
      key: key,
      fit: fit,
      child: child,
    );
  }
  factory OverlayWidgets.scrim({
    required Widget child,
    Alignment alignment = Alignment.bottomCenter,
    Key? key,
  }) {
    return OverlayWidgets._(
      alignment: alignment,
      widthFactor: 1.0,
      heightFactor: 1.0,
      key: key,
      fit: null, // Distinct from contain, means NO fitted box
      child: child,
    );
  }
  const OverlayWidgets._({
    required this.alignment,
    required this.child,
    super.key,
    this.widthFactor,
    this.heightFactor,
    this.fit = BoxFit.contain, // Default for other factories
  });
  final Alignment alignment;
  final Widget child;
  final double? widthFactor;
  final double? heightFactor;
  final BoxFit? fit;
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: FractionallySizedBox(
        widthFactor: widthFactor,
        heightFactor: heightFactor,
        child: ClipRect(
          child: fit == null ? child : FittedBox(fit: fit!, child: child),
        ),
      ),
    );
  }
}

class OverlayIcon extends StatelessWidget {
  const OverlayIcon(this.iconData, {super.key});
  final IconData iconData;

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: 0.3,
      heightFactor: 0.3,
      child: FittedBox(
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context).colorScheme.onSurface.withAlpha(
              192,
            ), // Color for the circular container
          ),
          child: Icon(
            iconData,
            color: const Color.fromARGB(192, 255, 255, 255),
            size: 64,
          ),
        ),
      ),
    );
  }
}
