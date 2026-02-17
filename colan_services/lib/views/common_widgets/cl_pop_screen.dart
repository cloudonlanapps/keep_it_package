import 'package:colan_services/views/page_manager.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../init_service/models/platform_support.dart';

enum CLScreenPopGesture { swipeLeft, onTap }

class CLPopScreen extends StatelessWidget {
  const CLPopScreen._({
    required this.child,
    required this.popGesture,
    required this.result,
    super.key,
  });

  factory CLPopScreen.onSwipe({
    required Widget child,
    Key? key,
    bool? result,
  }) {
    return CLPopScreen._(
      popGesture: CLScreenPopGesture.swipeLeft,
      key: key,
      result: result,
      child: child,
    );
  }
  factory CLPopScreen.onTap({
    required Widget child,
    Key? key,
    bool? result,
  }) {
    return CLPopScreen._(
      popGesture: CLScreenPopGesture.onTap,
      key: key,
      result: result,
      child: child,
    );
  }

  final Widget? child;
  final CLScreenPopGesture popGesture;
  final bool? result;

  @override
  Widget build(BuildContext context) {
    return CLKeyListener(
      keyHandler: {
        if (popGesture == CLScreenPopGesture.swipeLeft &&
            !ColanPlatformSupport.isMobilePlatform)
          LogicalKeyboardKey.escape: () => PageManager.of(context).pop(result),
      },
      child: GestureDetector(
        onTap: popGesture == CLScreenPopGesture.onTap
            ? () => PageManager.of(context).pop
            : null,
        onHorizontalDragEnd: popGesture == CLScreenPopGesture.swipeLeft
            ? (details) {
                if (details.primaryVelocity == null) return;
                // pop on Swipe
                if (details.primaryVelocity! > 0) {
                  PageManager.of(context).pop(result);
                }
              }
            : null,
        child: child,
      ),
    );
  }
}
