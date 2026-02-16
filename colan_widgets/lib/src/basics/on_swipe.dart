import 'package:flutter/material.dart';

class OnSwipe extends StatelessWidget {
  const OnSwipe({required this.child, required this.onSwipe, super.key});
  final Widget child;
  final VoidCallback onSwipe;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity == null) return;
        // pop on Swipe
        if (details.primaryVelocity! > 0) {
          onSwipe();
        }
      },
      child: child,
    );
  }
}
