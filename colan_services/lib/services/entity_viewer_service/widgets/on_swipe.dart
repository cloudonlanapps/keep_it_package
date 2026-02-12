import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../basic_page_service/widgets/page_manager.dart';

class OnSwipe extends ConsumerWidget {
  const OnSwipe({required this.child, super.key});
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity == null) return;
        // pop on Swipe
        if (details.primaryVelocity! > 0) {
          if (PageManager.of(context).canPop()) {
            PageManager.of(context).pop();
          }
        }
      },
      child: child,
    );
  }
}
