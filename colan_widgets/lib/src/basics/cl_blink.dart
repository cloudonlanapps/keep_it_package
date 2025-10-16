import 'dart:async';

import 'package:flutter/material.dart';

// To blink any widget with duration.
class CLBlink extends StatefulWidget {
  const CLBlink({
    required this.child,
    super.key,
    this.blinkDuration = Duration.zero,
  });
  final Duration blinkDuration;
  final Widget child;

  @override
  State<StatefulWidget> createState() => _BlinkerState();
}

class _BlinkerState extends State<CLBlink> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  @override
  void initState() {
    if (widget.blinkDuration != Duration.zero) {
      _animationController = AnimationController(
        vsync: this,
        duration: widget.blinkDuration,
      );
      unawaited(_animationController.repeat(reverse: true));
      Future.delayed(const Duration(seconds: 2), () {});
    }

    super.initState();
  }

  @override
  void dispose() {
    if (widget.blinkDuration != Duration.zero) {
      _animationController.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.blinkDuration == Duration.zero) {
      return widget.child;
    }

    return FadeTransition(
      opacity: _animationController,
      child: widget.child,
    );
  }
}
